#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

docker run -p 8082:8080 --network haproxy-net -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG --rm -ti haproxy-alpine-appliance $1
