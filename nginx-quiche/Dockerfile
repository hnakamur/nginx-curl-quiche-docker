# nginx with Cloudflare quiche
# https://github.com/cloudflare/quiche/blob/master/nginx/README.md

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y build-essential git cmake curl libpcre3-dev zlib1g-dev rustc

WORKDIR /src
RUN git clone --recursive https://github.com/cloudflare/quiche
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

CMD ["/src/nginx-1.16.1/objs/nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
