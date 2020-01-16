#!/bin/sh

cd /root/openssl && make install

export CURL_VERSION="7.66.0"

cd /root/curl-${CURL_VERSION}
CPPFLAGS="-I/opt/oqssa/include" \
        LDFLAGS=-Wl,-R/opt/oqssa/lib ./configure --prefix=/opt/oqssa \
                    --enable-debug \
                    --with-ssl=/opt/oqssa && \
    sed -i 's/EVP_MD_CTX_create/EVP_MD_CTX_new/g; s/EVP_MD_CTX_destroy/EVP_MD_CTX_free/g' lib/vtls/openssl.c && \
    make && make install;

cd /root/haproxy-master && make PREFIX="/opt/oqssa" LDFLAGS="-Wl,-rpath,/opt/oqssa/lib" SSL_INC=/opt/oqssa/include SSL_LIB=/opt/oqssa/lib TARGET=linux-glibc USE_OPENSSL=1 && make PREFIX="/opt/oqssa" install

