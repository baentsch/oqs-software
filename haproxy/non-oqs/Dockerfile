FROM ubuntu

RUN apt-get update -qq  && apt-get -y upgrade && apt-get install -y unzip lighttpd openssl libssl-dev wget build-essential rsyslog curl telnet

# build haproxy
WORKDIR /root
RUN wget https://github.com/haproxy/haproxy/archive/master.zip && unzip master.zip 

RUN cd /root/haproxy-master && make TARGET=linux-glibc USE_OPENSSL=1 && make install

WORKDIR /opt/haproxy
COPY startup.sh /opt/haproxy/startup.sh
COPY haproxy.cfg /opt/haproxy/haproxy.cfg
RUN echo "Hello World from lighthttpd backend. If you see this, all is fine: lighttpd data served via haproxy..." > /var/www/html/index.html

ENTRYPOINT ["/opt/haproxy/startup.sh"]
