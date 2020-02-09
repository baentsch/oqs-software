FROM alpine as intermediate

RUN apk update && apk upgrade 

# All SW-build and docker-image build prereqs
RUN apk add openssl make build-base linux-headers openssl-dev autoconf automake git libtool unzip wget 

ADD build-liboqs-openssl-curl-haproxy.sh /root/build-liboqs-openssl-curl-haproxy.sh
RUN /root/build-liboqs-openssl-curl-haproxy.sh

CMD ["/bin/sh"]

FROM alpine

MAINTAINER MIB (mib@zurich.ibm.com)

ENV DEBIAN_FRONTEND noninteractive

RUN apk update && apk upgrade && apk add lighttpd busybox-extras && rm -rf /var/cache/apk/*

# Change backend port to 8282 and change default web page:
ADD lighttpd.conf /etc/lighttpd/lighttpd.conf
RUN echo "Hello World from lighthttpd backend. If you see this, all is fine: lighttpd data served via haproxy protected by OQSSL..." > /var/www/localhost/htdocs/index.html

RUN addgroup -g 1000 -S oqs && adduser -u 1000 -S oqs -G oqs 

COPY --from=intermediate /opt /opt
ADD haproxy-server.cfg /opt/haproxy/server/haproxy.cfg
ADD haproxy-client.cfg /opt/haproxy/client/haproxy.cfg
ADD startup-client.sh /opt/haproxy/client/startup.sh
ADD startup-server.sh /opt/haproxy/server/startup.sh
ADD sh.sh /opt/haproxy/sh.sh
#ADD CA.crt /opt/haproxy/CA.crt

COPY upload.cgi /var/www/localhost/cgi-bin/upload.cgi
COPY mod_cgi.conf /etc/lighttpd/mod_cgi.conf
RUN chown -R oqs.oqs /opt/haproxy 
USER oqs
ENV PATH=/opt/oqssa/bin:/opt/oqssa/sbin:${PATH}
WORKDIR /opt/haproxy

# set to show algorithms actually used
ENV OQSINTERNALS 1

# set to disable usage warning
#ENV OQSWARNINGDISABLE 1

ENTRYPOINT ["/opt/haproxy/server/startup.sh"]
