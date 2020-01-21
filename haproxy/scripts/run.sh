#!/bin/bash

dir="$(dirname "$0")" && source "$dir/params.sh"

docker run -p 8080:80 -p 4443:443 -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG --add-host my.ha.proxy:127.0.0.1 -it haproxy-ubuntu 

