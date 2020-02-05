#!/bin/bash

BASENAME=haproxy-alpine

docker build -t $BASENAME .

if [ $# -gt 0 ]; then
   echo "Pushing image to openqsafe. Be sure to be logged in, eg via 'docker login -u openqsafe'"
   docker tag $BASENAME-dev openqsafe/$BASENAME && docker push openqsafe/$BASENAME
fi

