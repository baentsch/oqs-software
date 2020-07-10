#!/bin/bash


#./scripts/alpine-dockerbuild.sh
cd alpine && docker run --rm --env KEM_ALG=p384_kyber768 -p 4443:4443 -v `pwd`/oqs-haproxy:/opt/haproxy/conf -t haproxy-alpine  &
echo "Sleeping 10 seconds to allow docker image to start"
sleep 10
echo "Expected output if all is fine:"
echo "Hello World from lighthttpd backend. If you see this, all is fine: lighttpd data served via haproxy protected by OQSSL..."
/opt2/oqssa/bin/curl -k https://localhost:4443 --curves p384_kyber768

