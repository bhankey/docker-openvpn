


build:
	docker build . -t "openvpn_server"

run:
	docker run --name=openvpn_server -d --cap-add=NET_ADMIN -p 1194:1194/udp openvpn_server:latest

generate_client: 
	 docker exec -it openvpn_server /bin/sh
	 ./scripts/generate_client.sh $(CLIENT_NAME)
	 cat /etc/openvpn/client_configs/$(CLIENT_NAME)/client.ovpn