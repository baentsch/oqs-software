#!/bin/bash

if [ $# -ne 1 ]; then
   echo "Usage: $0 <DNS name of server>. Exiting."
   exit -1
fi

docker run -v /dev/log:/dev/log -v `pwd`/oqs-haproxy:/opt/haproxy -it haproxy-ubuntu bash -c "/opt/oqssa/bin/openssl req -new -newkey dilithium3 -keyout /opt/haproxy/server.key -out /opt/haproxy/server.csr -nodes -subj "/CN=$1" -config /opt/oqssa/ssl/openssl.cnf"

