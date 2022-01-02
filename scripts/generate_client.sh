#!/bin/sh

ClientConfigsPath='/etc/openvpn/client_configs'
EasyRSAPath="/etc/openvpn/easy-rsa"
OpenVPNPath="/etc/openvpn/keys"

UUID=$(uuidgen)
USER_DIR=$ClientConfigsPath/$UUID 

BASE_CONFIG=$ClientConfigsPath/base.conf

while [[ -e $USER_DIR ]]; do
    UUID=$(uuidgen)
    USER_DIR=$ClientConfigsPath/$UUID 
done

if [ -z "$HOST_ADDR" ]
    then
        HOST_ADDR='localhost'
fi

cd $EasyRSAPath


# Writing new private key to 'pki/private/{$UUID}.key
# Client sertificate pki/issued/{$UUID}.crt
# CA is by the path pki/ca.crt
./easyrsa build-client-full "$UUID" nopass &> /dev/null

cd /

mkdir -p $USER_DIR

cp $EasyRSAPath/pki/private/$UUID.key $EasyRSAPath/pki/issued/$UUID.crt $EasyRSAPath/pki/ca.crt -t $USER_DIR
cp $OpenVPNPath/ta.key -t $USER_DIR

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    $USER_DIR/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    $USER_DIR/$UUID.crt \
    <(echo -e '</cert>\n<key>') \
    $USER_DIR/$UUID.key \
    <(echo -e '</key>\n<tls-auth>') \
    $USER_DIR/ta.key \
    <(echo -e '</tls-auth>') \
    <(echo -e '\nremote $HOST_ADDR 1194') \
    > $USER_DIR/client.ovpn