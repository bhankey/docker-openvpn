
DOCKER_NAME = openvpn_server

RUN = docker exec $(DOCKER_NAME)

build:
	docker build . -t "$(DOCKER_NAME)"

run:
	docker run --name=$(DOCKER_NAME) -d --cap-add=NET_ADMIN -p 1194:1194/udp openvpn_server:latest

generate_client: 
	 $(RUN) ./scripts/generate_client.sh $(CLIENT_NAME)
	 $(RUN) cat /etc/openvpn/client_configs/$(CLIENT_NAME)/client.ovpn > $(CLIENT_NAME).ovpn