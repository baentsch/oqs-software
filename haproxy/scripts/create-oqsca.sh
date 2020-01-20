#!/bin/bash

docker run -v /dev/log:/dev/log -v `pwd`/oqs-root:/opt/haproxy/root -it haproxy-ubuntu bash -c "/opt/oqssa/bin/openssl req -x509 -new -newkey dilithium4 -keyout /opt/haproxy/root/CA.key -out /opt/haproxy/root/CA.crt -subj "/CN=OQS-HAproxy-CA" -days 365 -config /opt/oqssa/ssl/openssl.cnf"

