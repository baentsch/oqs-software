#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

mkdir -p oqs-root
# Mount local folder oqs-root to store generated root CA key and certificate:
docker run -v `pwd`/oqs-root:/opt/haproxy/root --entrypoint /opt/haproxy/sh.sh -it haproxy-alpine openssl req -x509 -new -newkey $SIG_ALG -keyout /opt/haproxy/root/CA.key -out /opt/haproxy/root/CA.crt -subj "/CN=OQS-HAproxy-CA" -days 365 -config /opt/oqssa/ssl/openssl.cnf

