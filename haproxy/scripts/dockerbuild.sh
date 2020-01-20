#!/bin/bash

BASENAME=haproxy-ubuntu

docker build -t $BASENAME .

if [ $# -gt 0 ]; then
   echo "Pushing image to openqsafe. Be sure to be logged in, eg via 'docker login -u openqsafe'"
   docker tag $BASENAME openqsafe/$BASENAME && docker push openqsafe/$BASENAME
fi
