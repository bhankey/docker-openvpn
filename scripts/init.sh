#!/bin/sh

EasyRSAPath="/etc/openvpn/easy-rsa"
OpenVPNPath="/etc/openvpn"
LockFile="/lock"

mkdir -p ~/client_configs/keys
chmod -R 700 ~/client-configs

mkdir -p /dev/net

if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

if [[ ! -e $LockFile ]]; then


    cd $EasyRSAPath
    # build ca service
    ./easyrsa build-ca nopass << EOF

EOF

    # generate and sign server sertificate
    ./easyrsa gen-req server nopass << EOF

EOF
    ./easyrsa sign-req server server << EOF 
    yes
EOF

    cp $EasyRSAPath/pki/ca.crt $EasyRSAPath/pki/private/server.key $EasyRSAPath/pki/issued/server.crt -t $OpenVPNPath/keys

    openvpn --genkey secret $OpenVPNPath/keys/ta.key
    chmod 777 $OpenVPNPath/keys/ta.key

    touch $LockFile
fi

cd /

#openvpn --config /etc/openvpn/server.conf
/bin/sh
