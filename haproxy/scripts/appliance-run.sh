#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

# Change 8082 to the port of choice where you want the appliance to be accessible at
docker run -p 8082:8080 --rm -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG --add-host my.ha.proxy:127.0.0.1 -ti haproxy-alpine-appliance $1

# For debugging, activate this line to log in to a shell prompt:
# docker run --rm -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG --entrypoint /bin/sh --add-host my.ha.proxy:127.0.0.1 -ti haproxy-alpine-appliance $1

