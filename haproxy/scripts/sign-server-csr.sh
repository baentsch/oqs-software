#!/bin/bash

# Mount both root CA and haproxy folders to generate haproxy server certificate:
docker run -v `pwd`/oqs-root:/opt/haproxy/root -v `pwd`/oqs-haproxy:/opt/haproxy/server --entrypoint /opt/haproxy/sh.sh -it haproxy-alpine openssl $OPENSSL x509 -req -in /opt/haproxy/server/server.csr -out /opt/haproxy/server/server.crt -CA /opt/haproxy/root/CA.crt -CAkey /opt/haproxy/root/CA.key -CAcreateserial -days 365

