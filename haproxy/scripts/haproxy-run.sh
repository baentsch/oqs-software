#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

# Only expose HAproxy at ports 8080 and 4443:
#docker run -v `pwd`/oqs-haproxy:/opt/haproxy/conf -p 8080:80 -p 4443:443 -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t openqsafe/haproxy-ubuntu $@

#Also expose lighttpd at port 8282:
docker run -v `pwd`/oqs-haproxy:/opt/haproxy/conf -p 8282:82 -p 8080:80 -p 4443:443 -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t openqsafe/haproxy-ubuntu $@

