#!/bin/bash

BASENAME=haproxy-alpine

docker build -t $BASENAME-dev .

if [ $# -gt 0 ]; then
   echo "Pushing image to openqsafe. Be sure to be logged in, eg via 'docker login -u openqsafe'"
   docker tag $BASENAME-dev openqsafe/$BASENAME && docker push openqsafe/$BASENAME
fi

sudo rm -rf opt/*
if [ ! -f opt.tgz ]; then
   docker run -v `pwd`/opt:/opt -it $BASENAME-dev /root/build-liboqs-openssl-curl-haproxy.sh
else
   tar xzvf opt.tgz
fi

# Build a small equivalent of haproxy-ubuntu
docker build -t $BASENAME-run -f Dockerfile-run .

# Build an even smaller appliance:
rm opt.tgz
tar czvf opt.tgz opt
sudo rm -rf opt/oqssa/lib/*.a opt/oqssa/doc opt/oqssa/share opt/bin/curl opt/lib/*curl*

cp ../oqs-root/CA.crt .

docker build -t $BASENAME-appliance -f Dockerfile-appliance .
