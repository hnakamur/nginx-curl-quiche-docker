# curl HTTP3 quiche version 
# https://github.com/curl/curl/blob/master/docs/HTTP3.md#quiche-version

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y build-essential git autoconf libtool rustc cmake

# Build quiche and BoringSSL
WORKDIR /src
RUN git clone --recursive https://github.com/cloudflare/quiche
WORKDIR /src/quiche
RUN cargo build --package quiche --release --features ffi,pkg-config-meta,qlog
RUN mkdir quiche/deps/boringssl/src/lib
RUN ln -vnf $(find target/release -name libcrypto.a -o -name libssl.a) quiche/deps/boringssl/src/lib/

# Build curl
WORKDIR /src
RUN git clone https://github.com/curl/curl
WORKDIR /src/curl
RUN apt-get install -y libpsl-dev libidn2-dev libgsasl7-dev pkg-config
RUN autoreconf -fi
RUN ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" --with-openssl=$PWD/../quiche/quiche/deps/boringssl/src --with-quiche=$PWD/../quiche/target/release
RUN make
RUN make install
RUN ldconfig
ENTRYPOINT ["/usr/local/bin/curl"]
