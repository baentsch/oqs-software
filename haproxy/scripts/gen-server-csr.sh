#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

if [ $# -ne 1 ]; then
   echo "Usage: $0 <DNS name of server>. Exiting."
   exit -1
fi

mkdir -p oqs-haproxy
# Mount local folder oqs-haproxy to store generated server key and CSR:
docker run -v `pwd`/oqs-haproxy:/opt/haproxy/server --entrypoint /opt/haproxy/sh.sh -it haproxy-alpine openssl req -new -newkey $SIG_ALG -keyout /opt/haproxy/server/server.key -out /opt/haproxy/server/server.csr -nodes -subj "/CN=$1" -config /opt/oqssa/ssl/openssl.cnf

