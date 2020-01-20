FROM ubuntu:19.10

RUN apt-get update -qq && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y gcc autoconf automake git libssl-dev libtool make unzip wget zlib1g-dev lighttpd

COPY build-liboqs-openssl-curl-haproxy.sh /root/build-liboqs-openssl-curl-haproxy.sh

RUN /root/build-liboqs-openssl-curl-haproxy.sh

COPY startup.sh /opt/haproxy/startup.sh
COPY haproxy.cfg /opt/haproxy/haproxy.cfg
COPY upload.cgi /usr/lib/cgi-bin/upload.cgi
RUN echo "Hello World from lighthttpd backend. If you see this, all is fine: lighttpd data served via haproxy protected by OQSSL..." > /var/www/html/index.html
WORKDIR /opt/haproxy

CMD ["/opt/haproxy/startup.sh"]
