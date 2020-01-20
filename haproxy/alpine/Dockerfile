FROM alpine

RUN apk update && apk upgrade 

# All SW-build and docker-image build prereqs
RUN apk add openssl make build-base linux-headers openssl-dev autoconf automake git libtool unzip wget 

ADD build-liboqs-openssl-curl-haproxy.sh /root/build-liboqs-openssl-curl-haproxy.sh

CMD ["/bin/sh"]
