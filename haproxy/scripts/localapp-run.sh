#!/bin/bash

# Change 8082 to the port of choice where you want the appliance to be accessible at
docker run -p 8082:8080 --rm --entrypoint /opt/haproxy/client/startup.sh --add-host my.ha.proxy:127.0.0.1 -ti haproxy-alpine $1

# For debugging, activate this line to log in to a shell prompt:
docker run -p 8082:8080 --rm -e OQSWARNINGDISABLE=1 --entrypoint /bin/sh --add-host my.ha.proxy:127.0.0.1 -ti haproxy-alpine 

