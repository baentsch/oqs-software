#!/bin/bash

BASENAME=haproxy-ubuntu

docker build -t $BASENAME .

if [ $# -gt 0 ]; then
   echo "Pushing image to openqsafe. Be sure to be logged in, eg via 'docker login -u openqsafe'"
   docker tag $BASENAME openqsafe/$BASENAME && docker push openqsafe/$BASENAME
fi

sudo rm -rf opt
mkdir opt
# Export installed dirs
docker run -v `pwd`/opt:/home/opt -t $BASENAME bash -c "cp -R /opt/* /home/opt"

rm -rf opt/bin/curl /opt/lib/*curl*

docker build -t $BASENAME-appliance -f Dockerfile-appliance .
