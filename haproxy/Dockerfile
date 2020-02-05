FROM ubuntu:19.10 as intermediate

RUN apt-get update -qq && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y gcc autoconf automake git libssl-dev libtool make unzip wget zlib1g-dev 

COPY build-liboqs-openssl-curl-haproxy.sh /root/build-liboqs-openssl-curl-haproxy.sh

RUN /root/build-liboqs-openssl-curl-haproxy.sh

COPY haproxy.cfg /opt/haproxy/haproxy.cfg
COPY upload.cgi /usr/lib/cgi-bin/upload.cgi

FROM ubuntu:19.10

RUN apt-get update -qq && apt-get upgrade -y && apt-get dist-upgrade -y  && apt install -y lighttpd


ADD lighttpd.conf /etc/lighttpd/lighttpd.conf
RUN echo "Hello World from lighttpd backend. If you see this, all is fine: lighttpd data served via haproxy protected by OQSSL..." > /var/www/html/index.html

COPY --from=intermediate /opt /opt

COPY startup-appliance.sh /opt/haproxy/startup.sh
COPY haproxy-appliance.cfg /opt/haproxy/haproxy.cfg
RUN useradd -ms /bin/bash oqs && chown -R oqs.oqs /opt/haproxy && lighttpd-enable-mod cgi 
USER oqs
WORKDIR /opt/haproxy
ENV PATH=/opt/oqssa/bin:${PATH}

CMD ["/opt/haproxy/startup.sh"]
