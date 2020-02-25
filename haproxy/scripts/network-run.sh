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
      docker stop my.ha.proxy localproxy> /dev/null 2>&1
      docker rm my.ha.proxy localproxy> /dev/null 2>&1
      docker network rm haproxy-net   > /dev/null 2>&1
      rm -rf ../oqs-root ../oqs-haproxy> /dev/null 2>&1
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

# Ensure image exists:
docker run --entrypoint /bin/echo -t haproxy-alpine 

if [ $? -ne 0 ]; then
   cd scripts && ./alpine-dockerbuild.sh && cd ..
fi

echo "Password requested is protecting the root CA key."
echo "Choose one in line with openssl minimum requirements."



# Create CA & server certs:
./scripts/create-oqsca.sh -s $SIG_ALG -k $KEM_ALG
./scripts/gen-server-csr.sh -s $SIG_ALG -k $KEM_ALG my.ha.proxy
./scripts/sign-server-csr.sh


# Start backend comprising of load-balancing haproxy fronting lighttpd
# Without external port-forwarding, haproxy serves off port 4443
docker run --network haproxy-net --name my.ha.proxy -v `pwd`/oqs-haproxy:/opt/haproxy/conf -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t haproxy-alpine &

# Build appliance with newly created CA cert baked in
cd oqs-root
echo "FROM haproxy-alpine" > Dockerfile-setca
echo "ADD CA.crt /opt/haproxy/CA.crt" >> Dockerfile-setca
echo "ENTRYPOINT [\"/opt/haproxy/client/startup.sh\"] " >> Dockerfile-setca

docker build -t haproxy-alpine-setca -f Dockerfile-setca .

# Start frontend haproxy appliance; switch port to network-internally accessible 4443
docker run -p $LOCALPORT:8080 --name localproxy --network haproxy-net --rm -e SIG_ALG=$SIG_ALG -e KEM_ALG=$KEM_ALG -t haproxy-alpine-setca &

echo "Now go to http://localhost:$LOCALPORT to access lighttpd via 2 tunneling haproxies..."
