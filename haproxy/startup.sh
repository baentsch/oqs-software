#!/bin/bash

if [ "x$KEM_ALG" == "x" ]; then
   # kem name not given
   export KEM_ALG=kyber512
fi

if [ "x$SIG_ALG" == "x" ]; then
   # sig name not given
   export SIG_ALG=dilithium4
fi

# Change backend port to 82 to match haproxy.cfg:
sed -e "s/\= 80/\= 82/g" -i /etc/lighttpd/lighttpd.conf 
# enable cgi
lighttpd-enable-mod cgi

# Start backend server:
service lighttpd start

# Configure SSL:
export OQSSA=/opt/oqssa
export OPENSSL=${OQSSA}/bin/openssl
export OPENSSL_CNF=${OQSSA}/ssl/openssl.cnf


cd /opt/haproxy
# Do on-the-fly generation only if server key not yet existing:
if [ ! -f /opt/haproxy/conf/server.key ]; then
mkdir -p conf 
mkdir -p root 
# generate CA key and cert
$OPENSSL req -x509 -new -newkey ${SIG_ALG} -keyout root/CA.key -out root/CA.crt -nodes -subj "/CN=oqstest CA" -days 365 -config ${OPENSSL_CNF} && \
# generate server CSR
$OPENSSL req -new -newkey ${SIG_ALG} -keyout conf/server.key -out conf/server.csr -nodes -subj "/CN=my.ha.proxy" -config ${OPENSSL_CNF} && \
# generate server cert
$OPENSSL x509 -req -in conf/server.csr -out conf/server.crt -CA root/CA.crt -CAkey root/CA.key -CAcreateserial -days 365;
cat /opt/haproxy/root/CA.crt
fi

# The location for haproxy.cfg
cat conf/server.crt conf/server.key > certkey.pem

sed -i "s/kyber512/$KEM_ALG/g" /opt/haproxy/haproxy.cfg

# Start HAProxy:
/opt/oqssa/sbin/haproxy -f /opt/haproxy/haproxy.cfg

