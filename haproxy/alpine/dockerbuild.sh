#!/bin/bash

BASENAME=haproxy-alpine

docker build -t $BASENAME-dev .

if [ $# -gt 0 ]; then
   echo "Pushing image to openqsafe. Be sure to be logged in, eg via 'docker login -u openqsafe'"
   docker tag $BASENAME openqsafe/$BASENAME && docker push openqsafe/$BASENAME
fi

sudo rm -rf opt/*
docker run -v `pwd`/opt:/opt -it $BASENAME /root/build-liboqs-openssl-curl-haproxy.sh

docker build -t $BASENAME-run -f Dockerfile-run .

rm opt.tgz
tar czvf opt.tgz opt
sudo rm -rf opt/oqssa/lib/*.a opt/oqssa/doc opt/oqssa/share

cp ../oqs-root/CA.crt .

docker build -t $BASENAME-appliance -f Dockerfile-appliance .
