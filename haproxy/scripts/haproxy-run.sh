#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

docker run -v `pwd`/oqs-haproxy:/opt/haproxy/conf -p 8080:80 -p 4443:443 -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -it haproxy-ubuntu $@

