#!/bin/bash

docker run -p 8081:80 -p 4444:443 --add-host my.ha.proxy:127.0.0.1 -t haproxy-plain

