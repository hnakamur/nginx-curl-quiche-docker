nginx-curl-quiche-build-docker
==============================

A Dockerfile for curl-quiche and nginx-quiche using
[cloudflare/quiche: 🥧 Savoury implementation of the QUIC transport protocol and HTTP/3](https://github.com/cloudflare/quiche).

## How to build

```
docker build -t nginx-curl-quiche .
```

## How to run

Run nginx in a Docker container.

```
docker run --rm nginx-curl-quiche
```

Run curl inside the above container.

```
docker exec -it $(docker ps -q) curl -kv --http3 https://127.0.0.1
```
