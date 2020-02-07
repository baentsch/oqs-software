#!/bin/bash


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
      docker stop my.ha.proxy localproxy
      docker rm my.ha.proxy localproxy
      docker network rm haproxy-net   
      rm -rf ../oqs-root ../oqs-haproxy
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
docker network create haproxy-net

cd ..

# Ensure image exists:
docker run -t haproxy-ubuntu /bin/echo

if [ $? -ne 0 ]; then
   ./scripts/dockerbuild.sh
fi

# Create CA & server certs:
./scripts/create-oqsca.sh -s $SIG_ALG -k $KEM_ALG
./scripts/gen-server-csr.sh -s $SIG_ALG -k $KEM_ALG my.ha.proxy
./scripts/sign-server-csr.sh

# Ensure image exists:
docker run --entrypoint /bin/echo -t haproxy-alpine 

if [ $? -ne 0 ]; then
   cd alpine && ./dockerbuild.sh && cd ..
fi

# Start backend comprising of load-balancing haproxy fronting lighttpd
# Without external port-forwarding, haproxy serves off port 443
docker run --network haproxy-net --name my.ha.proxy -v `pwd`/oqs-haproxy:/opt/haproxy/conf -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t haproxy-alpine &

# Build appliance with newly created CA cert baked in
cp oqs-root/CA.crt alpine
cd alpine

docker build -t haproxy-alpine-setca -f Dockerfile-setca .

# Start frontend haproxy appliance; switch port to network-internally accessible 443
docker run -p $LOCALPORT:8080 --name localproxy --network haproxy-net --rm -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t haproxy-alpine-setca &

echo "Now go to http://localhost:$LOCALPORT to access lighttpd via 2 tunneling haproxies..."
