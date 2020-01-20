#!/bin/bash

docker run -v /dev/log:/dev/log -v `pwd`/oqs-root:/opt/haproxy/root -v `pwd`/oqs-haproxy:/opt/haproxy -it haproxy-ubuntu bash -c "/opt/oqssa/bin/openssl $OPENSSL x509 -req -in /opt/haproxy/server.csr -out /opt/haproxy/server.crt -CA /opt/haproxy/root/CA.crt -CAkey /opt/haproxy/root/CA.key -CAcreateserial -days 365"

