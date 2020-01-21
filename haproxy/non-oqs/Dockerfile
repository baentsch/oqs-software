FROM ubuntu

RUN apt-get update -qq  && apt-get -y upgrade && apt-get install -y unzip lighttpd openssl libssl-dev wget build-essential rsyslog curl telnet

# build haproxy
WORKDIR /root
RUN wget https://github.com/haproxy/haproxy/archive/master.zip && unzip master.zip 

RUN cd /root/haproxy-master && make TARGET=linux-glibc USE_OPENSSL=1 && make install

WORKDIR /opt/haproxy
COPY startup.sh /opt/haproxy/startup.sh
COPY haproxy.cfg /opt/haproxy/haproxy.cfg
COPY upload.cgi /usr/lib/cgi-bin/upload.cgi
COPY 10-cgi.conf /etc/lighttpd/conf-enabled/10-cgi.conf
RUN echo "Hello World from lighthttpd backend. If you see this, all is fine: lighttpd data (possibly served via haproxy with classic crypto)..." > /var/www/html/index.html

ENTRYPOINT ["/opt/haproxy/startup.sh"]
