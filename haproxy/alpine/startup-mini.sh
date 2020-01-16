#!/bin/sh

# Configure SSL:
export OQSSA=/opt/oqssa
export OPENSSL=${OQSSA}/bin/openssl
export OPENSSL_CNF=${OQSSA}/ssl/openssl.cnf

export SIG_ALG=dilithium4

cd /opt/haproxy
# generate CA key and cert
$OPENSSL req -x509 -new -newkey ${SIG_ALG} -keyout CA.key -out CA.crt -nodes -subj "/CN=oqstest CA" -days 365 -config ${OPENSSL_CNF} && \
# generate server CSR
$OPENSSL req -new -newkey ${SIG_ALG} -keyout server.key -out server.csr -nodes -subj "/CN=my.ha.proxy" -config ${OPENSSL_CNF} && \
# generate server cert
$OPENSSL x509 -req -in server.csr -out server.crt -CA CA.crt -CAkey CA.key -CAcreateserial -days 365;

cat server.crt server.key > certkey.pem

# Start HAProxy:
/opt/oqssa/sbin/haproxy -D -f /opt/haproxy/haproxy.cfg

cat /opt/haproxy/CA.crt
/bin/sh
