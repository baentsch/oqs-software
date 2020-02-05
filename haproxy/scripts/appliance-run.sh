#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

# If parameter is given, designates Backend address to be protected (form: <addr:port>)
if [ $# -eq 1 ]; then
	export BACKEND=$1
	shift 1
fi

# Change 4449 to the port of choice where you want the appliance to be accessible at
docker run -p 4449:443 --rm -v `pwd`/oqs-haproxy:/opt/haproxy/conf -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -e BACKEND=$BACKEND --add-host my.ha.proxy:127.0.0.1 -ti haproxy-ubuntu $@

# For debugging, activate this line to log in to a shell prompt:
# docker run --rm -v `pwd`/oqs-haproxy:/opt/haproxy/conf -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG --entrypoint /bin/sh --add-host my.ha.proxy:127.0.0.1 -ti haproxy-alpine $@

