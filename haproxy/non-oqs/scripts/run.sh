#!/bin/bash

docker run -v /dev/log:/dev/log -p 8081:80 -p 4444:443 --add-host my.ha.proxy:127.0.0.1 -it haproxy-plain

