#!/bin/sh
set -e
set -x

if [ ${OCPROXY_ENABLE:='0'} = "1" ]
then
  echo $VPN_PASSWORD | \
  openconnect --quiet --cookieonly $OPENCONNECT_OPTIONS --disable-ipv6 --protocol=nc --os=linux --user=$VPN_USER --passwd-on-stdin $VPN_URL | \
  openconnect --background $OPENCONNECT_OPTIONS --disable-ipv6 --protocol=nc --os=linux --script-tun --script="ocproxy -D ${OCPROXY_PORT:=2222} -g" --cookie-on-stdin $VPN_URL
else
  echo $VPN_PASSWORD | \
  openconnect --quiet --cookieonly $OPENCONNECT_OPTIONS --disable-ipv6 --protocol=nc --os=linux --user=$VPN_USER --passwd-on-stdin $VPN_URL | \
  openconnect --background $OPENCONNECT_OPTIONS --disable-ipv6 --protocol=nc --os=linux --cookie-on-stdin $VPN_URL
  iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
  iptables -A FORWARD -i eth0 -j ACCEPT
fi
