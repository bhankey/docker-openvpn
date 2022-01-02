FROM alpine:3.15.0

RUN apk add --no-cache openvpn easy-rsa uuidgen

RUN mv /usr/share/easy-rsa /etc/openvpn

COPY ./configs/easyrsa.conf /etc/openvpn/easy-rsa/vars
COPY ./configs/openvpn.conf /etc/openvpn/server.conf
COPY ./configs/openvpnclient.conf /etc/openvpn/client_configs/base.conf

COPY ./scripts /scripts

WORKDIR /etc/openvpn/easy-rsa

RUN ./easyrsa init-pki && ./easyrsa gen-dh

RUN mkdir /etc/openvpn/keys && cp pki/dh.pem /etc/openvpn/keys

RUN command

WORKDIR /

CMD [ "/bin/sh", "scripts/init.sh" ]