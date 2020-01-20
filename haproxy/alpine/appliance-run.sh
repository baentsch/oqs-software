#!/bin/bash

docker run -p 8082:8080 --network haproxy-net --rm -ti haproxy-alpine-appliance $1
