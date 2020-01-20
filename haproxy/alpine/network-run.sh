#!/bin/bash

PORT=8082

# if parameter is given, cleanup first
if [ $# -eq 1 ]; then
   docker stop my.ha.proxy
   docker rm my.ha.proxy
   docker network rm haproxy-net   
   sudo rm -rf ../oqs-*
fi

# Establish network in which to run
docker network create haproxy-net

# Create CA & server certs:
cd ..
./scripts/create-oqsca.sh
./scripts/gen-server-csr.sh my.ha.proxy
./scripts/sign-server-csr.sh

# Start backend comprising of load-balancing haproxy fronting lighttpd
docker run --network haproxy-net --name my.ha.proxy -v `pwd`/oqs-haproxy:/opt/haproxy/conf -t haproxy-ubuntu &

# Build appliance with newly created CA cert baked in
cp oqs-root/CA.crt alpine
cd alpine

BASENAME=haproxy-alpine
docker build -t $BASENAME-appliance -f Dockerfile-appliance .

# Start frontend haproxy appliance
docker run -p $PORT:8080 --network haproxy-net --rm -t haproxy-alpine-appliance &

echo "Now go to http://localhost:$PORT to access lighttpd via 2 haproxies..."
