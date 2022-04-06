nginx-curl-quiche-build-docker
==============================

A Dockerfile for curl-quiche and nginx-quiche using
[cloudflare/quiche: 🥧 Savoury implementation of the QUIC transport protocol and HTTP/3](https://github.com/cloudflare/quiche).

## How to build and run nginx-quiche and curl-quiche using docker-compose

```
make
```

## How to build and run nginx-quiche and curl-quiche using docker

Build and nginx-quiche in a Docker container.

```
make run-nginx-quiche
```

In another terminal, build and run curl-quiche and send request to the nginx-quiche above.

```
make run-curl-quiche-http3
```
