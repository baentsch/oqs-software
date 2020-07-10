#!/bin/sh

if [ "x$KEM_ALG" != "x" ]; then
   # kem name given, set it
   echo "Setting KEM alg $KEM_ALG"
   sed -i "s/kyber768/$KEM_ALG/g" /opt/haproxy/client/haproxy.cfg
fi

cd /opt/haproxy

if [ $# -eq 1 ]; then
   # QSC server-side proxy address as sole optional parameter
   echo "Setting target server side HAproxy $1"
   sed -i "s/my.ha.proxy:4443/$1/g" /opt/haproxy/client/haproxy.cfg 
fi

if [ "x$DISABLE_CERT_CHECK" != "x" ]; then
   sed -i "s/ca-file \/opt\/haproxy\/conf\/CA.crt verify required/verify none/g" /opt/haproxy/client/haproxy.cfg 
fi

# Start HAProxy:
/opt/oqssa/sbin/haproxy -f /opt/haproxy/client/haproxy.cfg
