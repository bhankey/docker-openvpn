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

# Allow UDP traffic on port 1194.
iptables -A INPUT -i eth0 -p udp -m state --state NEW,ESTABLISHED --dport 1194 -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED --sport 1194 -j ACCEPT

# Allow traffic on the TUN interface.
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT

# Allow forwarding traffic only from the VPN.
iptables -A FORWARD -i tun0 -o eth0 -s 10.8.0.0/24 -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

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
