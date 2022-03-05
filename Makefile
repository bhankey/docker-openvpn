
build:
	docker build . -t "openvpn_server"

run:
	docker run -d --cap-add=NET_ADMIN -p 1194:1194/udp openvpn_server:latest