#!/bin/sh

ClientConfigsPath='/etc/openvpn/client_configs'
EasyRSAPath="/etc/openvpn/easy-rsa"
OpenVPNKeyPath="/etc/openvpn/keys"

if [ -z "$1" ] 
    then 
        UUID=$(uuidgen)
else
        UUID=$1
fi

echo "sertificate name for new client $UUID"

USER_DIR=$ClientConfigsPath/$UUID 

BASE_CONFIG=$ClientConfigsPath/base.conf

IP=$(wget -O - -q https://checkip.amazonaws.com)

# Проверяем на существование сертификата с таким же именем
if [[ -e $USER_DIR ]] 
    then
        echo "sertifacete in dir $USER_DIR already created"
        exit 1
fi

if [ -z "$HOST_ADDR" ]
    then
        HOST_ADDR='localhost'
fi

cd $EasyRSAPath


# Writing new private key to 'pki/private/{$UUID}.key
# Client sertificate pki/issued/{$UUID}.crt
./easyrsa build-client-full "$UUID" nopass &> /dev/null

cd /

mkdir -p $USER_DIR

cp $EasyRSAPath/pki/private/$UUID.key $EasyRSAPath/pki/issued/$UUID.crt -t $USER_DIR

cat ${BASE_CONFIG} \
    <(echo -e "\nremote $IP 1194\n") \
    <(echo -e '\n<ca>') \
    $OpenVPNKeyPath/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    $USER_DIR/$UUID.crt \
    <(echo -e '</cert>\n<key>') \
    $USER_DIR/$UUID.key \
    <(echo -e '</key>\n<tls-auth>') \
    $OpenVPNKeyPath/ta.key \
    <(echo -e '</tls-auth>') \
    > $USER_DIR/client.ovpn

echo "sertificate created in $USER_DIR"