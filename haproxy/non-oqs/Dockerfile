FROM ubuntu

RUN apt-get update -qq  && apt-get -y upgrade && apt-get install -y unzip lighttpd openssl libssl-dev wget build-essential rsyslog curl telnet

# build haproxy
WORKDIR /root
RUN wget https://github.com/haproxy/haproxy/archive/master.zip && unzip master.zip 

RUN cd /root/haproxy-master && make TARGET=linux-glibc USE_OPENSSL=1 && make install

WORKDIR /opt/haproxy
COPY startup.sh /opt/haproxy/startup.sh
COPY haproxy.cfg /opt/haproxy/haproxy.cfg

ENTRYPOINT ["/opt/haproxy/startup.sh"]
