#!/bin/bash

# Showing all components working together in a docker network 'haproxy-demo-net':
# ha-localproxy is the instance establishing a plain HTTP frontend towards a QSC-enabled, server side haproxy below:
# my.ha.proxy is the instance establishing a QSC-enabled frontend towards a plain HTTP backend demo server (lighttpd server embedded in the image)

# default values:
LOCALPORT=8082
SIG_ALG=dilithium4
KEM_ALG=kyber512

PARAMS=""

while (( "$#" )); do
  case "$1" in
    -k|--kem)
      KEM_ALG=$2
      shift 2
      ;;
    -s|--sig)
      SIG_ALG=$2
      shift 2
      ;;
    -p|--port)
      LOCALPORT=$2
      shift 2
      ;;
    -c|--clean)
      docker stop ha-localproxy my.ha.proxy > /dev/null 2>&1
      docker rm ha-localproxy my.ha.proxy > /dev/null 2>&1
      docker network rm haproxy-demo-net  > /dev/null 2>&1 
      rm -rf oqs-root oqs-haproxy> /dev/null 2>&1
      shift 1 
      ;;
    --) 
      shift
      break
      ;;
    -*|--*=) 
      echo "Usage: $0 [--sig <OQS signature algorithm name>] "
      echo "          [--kem <OQS KEM algorithm name>]"
      echo "          [--port <localhost port number where to make appliance accessible>]"
      echo "          [--clean]"
      echo "Exiting."
      exit 1
      ;;
    *) 
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
eval set -- "$PARAMS"

# Establish network in which to run
docker network create haproxy-demo-net > /dev/null 2>&1 

echo "Password requested is protecting the root CA key."
echo "Choose one in line with openssl minimum requirements."

# Create CA & server certs:
mkdir -p oqs-root
# Mount local folder oqs-root to store generated root CA key and certificate:
docker run -v `pwd`/oqs-root:/opt/haproxy/root --entrypoint /opt/haproxy/sh.sh -it openqsafe/haproxy-alpine openssl req -x509 -new -newkey $SIG_ALG -keyout /opt/haproxy/root/CA.key -out /opt/haproxy/root/CA.crt -subj "/CN=OQS-HAproxy-CA" -days 365 -config /opt/oqssa/ssl/openssl.cnf

mkdir -p oqs-haproxy
# Mount local folder oqs-haproxy to store generated server key and CSR:
docker run -v `pwd`/oqs-haproxy:/opt/haproxy/server --entrypoint /opt/haproxy/sh.sh -it openqsafe/haproxy-alpine openssl req -new -newkey $SIG_ALG -keyout /opt/haproxy/server/server.key -out /opt/haproxy/server/server.csr -nodes -subj "/CN=my.ha.proxy" -config /opt/oqssa/ssl/openssl.cnf

# Mount both root CA and haproxy folders to generate haproxy server certificate:
docker run -v `pwd`/oqs-root:/opt/haproxy/root -v `pwd`/oqs-haproxy:/opt/haproxy/server --entrypoint /opt/haproxy/sh.sh -it openqsafe/haproxy-alpine openssl x509 -req -in /opt/haproxy/server/server.csr -out /opt/haproxy/server/server.crt -CA /opt/haproxy/root/CA.crt -CAkey /opt/haproxy/root/CA.key -CAcreateserial -days 365

# Start backend comprising of load-balancing haproxy fronting lighttpd
# Without external port-forwarding, haproxy serves off port 4443
docker run --network haproxy-demo-net --name my.ha.proxy -v `pwd`/oqs-haproxy:/opt/haproxy/conf -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t openqsafe/haproxy-alpine &

# Build appliance with newly created CA cert baked in
cd oqs-root
echo "FROM openqsafe/haproxy-alpine" > Dockerfile-setca
echo "ADD CA.crt /opt/haproxy/CA.crt" >> Dockerfile-setca
echo "ENTRYPOINT [\"/opt/haproxy/client/startup.sh\"] " >> Dockerfile-setca

docker build -t haproxy-alpine-setca -f Dockerfile-setca .

# Start frontend haproxy appliance; switch port to network-internally accessible 443
docker run -p $LOCALPORT:8080 --name ha-localproxy --network haproxy-demo-net --rm -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t haproxy-alpine-setca &

echo "Now go to http://localhost:$LOCALPORT to access lighttpd via 2 tunneling haproxies..."
