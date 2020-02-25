FROM ubuntu:19.10 as intermediate

RUN apt-get update -qq && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y gcc autoconf automake git libssl-dev libtool make unzip wget zlib1g-dev cmake

COPY build-liboqs-openssl-curl-haproxy.sh /root/build-liboqs-openssl-curl-haproxy.sh

RUN /root/build-liboqs-openssl-curl-haproxy.sh

FROM ubuntu:19.10

RUN apt-get update -qq && apt-get upgrade -y && apt-get dist-upgrade -y  && apt install -y lighttpd

# Only obtain installed/binary artifacts:
COPY --from=intermediate /opt /opt

# Prepare lighttpd config
COPY upload.cgi /usr/lib/cgi-bin/upload.cgi
ADD lighttpd.conf /etc/lighttpd/lighttpd.conf
RUN echo "Hello World from lighttpd backend. If you see this, all is fine: lighttpd data served via haproxy protected by OQSSL..." > /var/www/html/index.html

# Prepare server-side components
COPY startup.sh /opt/haproxy/startup.sh
COPY haproxy.cfg /opt/haproxy/haproxy.cfg

# Remove need for running as root
RUN useradd -ms /bin/bash oqs && chown -R oqs.oqs /opt/haproxy && lighttpd-enable-mod cgi 
USER oqs
WORKDIR /opt/haproxy
ENV PATH=/opt/oqssa/bin:${PATH}

CMD ["/opt/haproxy/startup.sh"]
