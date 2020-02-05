#!/bin/sh

if [ "x$KEM_ALG" != "x" ]; then
   # kem name given, set it
   echo "Setting KEM alg $KEM_ALG"
   sed -i "s/kyber512/$KEM_ALG/g" /opt/haproxy/server/haproxy.cfg
fi

cd /opt/haproxy

if [ $# -eq 1 ]; then
   # server address as sole optional parameter
   echo "Setting target HAproxy $1"
   sed -i "s/my.ha.proxy:4443/$1/g" /opt/haproxy/server/haproxy.cfg 
fi

if [ "x$DISABLE_CERT_CHECK" != "x" ]; then
   sed -i "s/required/none/g" /opt/haproxy/server/haproxy.cfg 
fi

# Start backend:
lighttpd -D -f /etc/lighttpd/lighttpd.conf &

sleep 2

cat conf/server.crt conf/server.key > certkey.pem

# Start HAProxy:
/opt/oqssa/sbin/haproxy -f /opt/haproxy/server/haproxy.cfg

