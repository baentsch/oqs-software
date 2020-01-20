#!/bin/bash

docker run -v /dev/log:/dev/log -p 8080:80 -p 4443:443 --add-host my.ha.proxy:127.0.0.1 -it haproxy-plain

