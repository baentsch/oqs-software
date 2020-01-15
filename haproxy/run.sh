#!/bin/bash

#docker run -p 80:80 -p 443:443 --add-host my.back.end:127.0.0.1 -it oqssa-haproxy
docker run -p 80:80 -p 443:443 --add-host my.back.end:127.0.0.1 -it oqssa-haproxy-plain

