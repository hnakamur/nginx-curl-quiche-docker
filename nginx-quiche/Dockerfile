# nginx with Cloudflare quiche
# https://github.com/cloudflare/quiche/blob/master/nginx/README.md

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y build-essential git cmake curl libpcre3-dev zlib1g-dev rustc

WORKDIR /src
RUN git clone --recursive https://github.com/cloudflare/quiche
RUN curl -O https://nginx.org/download/nginx-1.21.6.tar.gz
RUN tar xzvf nginx-1.21.6.tar.gz
WORKDIR /src/nginx-1.21.6
COPY nginx-1.21.6-quiche.patch /src/
RUN patch -p01 < /src/nginx-1.21.6-quiche.patch
RUN ./configure                                \
       --prefix=/usr                           \
       --build="quiche-$(git --git-dir=../quiche/.git rev-parse --short HEAD)" \
       --with-http_ssl_module                  \
       --with-http_v2_module                   \
       --with-http_v3_module                   \
       --with-openssl=../quiche/quiche/deps/boringssl \
       --with-quiche=../quiche
RUN make
RUN make install

RUN mkdir -p /etc/nginx /var/log/nginx
RUN ln -s /dev/stdout /var/log/nginx/access.log
RUN ln -s /dev/stderr /var/log/nginx/error.log

CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
