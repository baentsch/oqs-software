#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

if [ $# -ne 1 ]; then
   echo "Usage: $0 <DNS name of server>. Exiting."
   exit -1
fi

# Mount local folder oqs-haproxy to store generated server key and CSR:
docker run -v `pwd`/oqs-haproxy:/opt/haproxy -it haproxy-ubuntu bash -c "/opt/oqssa/bin/openssl req -new -newkey $SIG_ALG -keyout /opt/haproxy/server.key -out /opt/haproxy/server.csr -nodes -subj "/CN=$1" -config /opt/oqssa/ssl/openssl.cnf"

