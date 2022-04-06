all: server.crt
	docker-compose up --abort-on-container-exit

server.crt:
	openssl req -new -newkey rsa:2048 -sha1 -x509 -nodes \
		-set_serial 1 \
		-days 365 \
		-subj "/C=JP/ST=Osaka/L=Osaka City/CN=example.com" \
		-out server.crt \
		-keyout server.key


# targets using docker instead of docker-compose

run-nginx-quiche: build-nginx-quiche-image build-nginx-quiche-network
	sudo docker run --rm --name nginx-quiche \
		--network=nginx-quiche \
		-p 443:443/tcp -p 443:443/udp \
		-v ${PWD}/nginx-quiche/nginx.conf:/etc/nginx/nginx.conf:ro \
		-v ${PWD}/nginx-quiche/docroot:/var/www/html:ro \
		-v ${PWD}/server.crt:/etc/nginx/cert.crt:ro \
		-v ${PWD}/server.key:/etc/nginx/cert.key:ro \
		nginx-quiche

run-curl-quiche-http3: build-curl-quiche-image
	( \
	nginx_ip=$$(docker inspect --format '{{ $$network := index .NetworkSettings.Networks "nginx-quiche" }}{{ $$network.IPAddress }}' nginx-quiche); \
	docker run --rm --network=nginx-quiche curl-quiche -kv --http3 https://$${nginx_ip} \
	)

run-curl-quiche-http2: build-curl-quiche-image
	( \
	nginx_ip=$$(docker inspect --format '{{ $$network := index .NetworkSettings.Networks "nginx-quiche" }}{{ $$network.IPAddress }}' nginx-quiche); \
	docker run --rm --network=nginx-quiche curl-quiche -kv https://$${nginx_ip} \
	)

build-nginx-quiche-image:
	[ -n "$$(docker images -q nginx-quiche)" ] || \
	(cd nginx-quiche; docker build -t nginx-quiche .)

build-curl-quiche-image:
	[ -n "$$(docker images -q curl-quiche)" ] || \
	(cd curl-quiche; docker build -t curl-quiche .)

build-nginx-quiche-network:
	[ -n "$$(docker network ls -q -f name=nginx-quiche)" ] || \
	docker network create --driver=bridge nginx-quiche
