#!/bin/bash

cp ../upload.cgi .
docker build -t haproxy-plain .
rm upload.cgi
