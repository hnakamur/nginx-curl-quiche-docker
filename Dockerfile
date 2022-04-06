# curl HTTP3 quiche version 
# https://github.com/curl/curl/blob/master/docs/HTTP3.md#quiche-version

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y build-essential git cmake curl libpcre3-dev zlib1g-dev rustc

# Build quiche and BoringSSL
WORKDIR /src
RUN git clone --recursive https://github.com/cloudflare/quiche

# https://github.com/cloudflare/quiche/blob/master/nginx/README.md
WORKDIR /src
RUN curl -O https://nginx.org/download/nginx-1.16.1.tar.gz
RUN tar xzvf nginx-1.16.1.tar.gz
WORKDIR /src/nginx-1.16.1
RUN patch -p01 < ../quiche/nginx/nginx-1.16.patch
RUN ./configure                                 \
       --prefix=$PWD                           \
       --build="quiche-$(git --git-dir=../quiche/.git rev-parse --short HEAD)" \
       --with-http_ssl_module                  \
       --with-http_v2_module                   \
       --with-http_v3_module                   \
       --with-openssl=../quiche/quiche/deps/boringssl \
       --with-quiche=../quiche
RUN make
RUN mkdir logs

RUN mkdir /etc/nginx
RUN openssl req -new -newkey rsa:2048 -sha1 -x509 -nodes \
    -set_serial 1 \
    -days 365 \
    -subj "/C=JP/ST=Osaka/L=Osaka City/CN=example.com" \
    -out /etc/nginx/cert.crt \
    -keyout /etc/nginx/cert.key
COPY nginx.conf /etc/nginx/

# Build quiche and BoringSSL for curl-quiche
RUN apt-get install -y build-essential git autoconf libtool rustc cmake
WORKDIR /curl-quiche/src
RUN git clone --recursive https://github.com/cloudflare/quiche
WORKDIR /curl-quiche/src/quiche
RUN cargo build --package quiche --release --features ffi,pkg-config-meta,qlog
RUN mkdir quiche/deps/boringssl/src/lib
RUN ln -vnf $(find target/release -name libcrypto.a -o -name libssl.a) quiche/deps/boringssl/src/lib/

# Build curl-quiche
WORKDIR /curl-quiche/src
RUN git clone https://github.com/curl/curl
WORKDIR /curl-quiche/src/curl
RUN apt-get install -y libpsl-dev libidn2-dev libgsasl7-dev pkg-config
RUN autoreconf -fi
RUN ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" --with-openssl=$PWD/../quiche/quiche/deps/boringssl/src --with-quiche=$PWD/../quiche/target/release
RUN make
RUN make install
RUN ldconfig

CMD ["/src/nginx-1.16.1/objs/nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
