#!/bin/bash

BASENAME=haproxy-alpine-dev

docker build -t $BASENAME .

if [ $# -gt 0 ]; then
   echo "Pushing image to openqsafe. Be sure to be logged in, eg via 'docker login -u openqsafe'"
   docker tag $BASENAME openqsafe/$BASENAME && docker push openqsafe/$BASENAME
fi

sudo rm -rf opt/*
docker run -v `pwd`/opt:/opt -it $BASENAME /root/install.sh

docker build -t $BASENAME-run -f Dockerfile-run
