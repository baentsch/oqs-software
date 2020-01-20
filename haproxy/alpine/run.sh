#!/bin/bash

docker run --add-host my.ha.proxy:127.0.0.1 -it haproxy-alpine-dev-run  /opt/haproxy/startup.sh
