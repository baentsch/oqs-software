FROM openqsafe/liboqs-ubuntu-bionic-dev

RUN apt-get update -qq  && apt-get -y upgrade && apt-get install -y unzip lighttpd

# build haproxy
WORKDIR /root
RUN wget https://github.com/haproxy/haproxy/archive/master.zip && unzip master.zip 

RUN cd /root/haproxy-master && make LDFLAGS="-Wl,-rpath,/opt/oqssa/lib" SSL_INC=/opt/oqssa/include SSL_LIB=/opt/oqssa/lib TARGET=linux-glibc USE_OPENSSL=1 && make install

# build curl
WORKDIR /root
ENV CURL_VERSION 7.66.0

RUN wget https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz && tar -zxvf curl-${CURL_VERSION}.tar.gz;

WORKDIR /root/curl-${CURL_VERSION}
RUN env CPPFLAGS="-I/opt/ossl-src/oqs/include" \
        LDFLAGS=-Wl,-R/opt/oqssa/lib ./configure --prefix=/opt/curl \
                    --enable-debug \
                    --with-ssl=/opt/oqssa && \
    sed -i 's/EVP_MD_CTX_create/EVP_MD_CTX_new/g; s/EVP_MD_CTX_destroy/EVP_MD_CTX_free/g' lib/vtls/openssl.c && \
    make && make install;


WORKDIR /opt/haproxy
COPY startup.sh /opt/haproxy/startup.sh
COPY haproxy.cfg /opt/haproxy/haproxy.cfg

#
## forward request and error logs to docker log collector
#RUN ln -sf /dev/stdout /opt/httpd/logs/access_log && \
#    ln -sf /dev/stderr /opt/httpd/logs/error_log;
#
#EXPOSE 4433
#
#STOPSIGNAL SIGTERM

#CMD ["/opt/httpd/bin/httpd", "-DFOREGROUND"]
ENTRYPOINT ["/opt/haproxy/startup.sh"]
