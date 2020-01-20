#!/bin/sh

export GITNAME=`git rev-parse --abbrev-ref HEAD`
export GITREV=`git rev-parse --short HEAD`
sed -i "s/static int stoperrset = 0;/static int stoperrset = 0; if (\!getenv(\"OQSWARNINGDISABLE\")) printf(\"OQS-enabled OpenSSL ($GITNAME, $GITREV) starting. Only for non-productive use. \\\nSee https:\/\/github.com\/open-quantum-safe\/openssl#limitations-and-security\\\n\");/g" ssl/ssl_init.c
sed -i "s/\/\* initialize the kex \*\//if (getenv(\"OQSINTERNALS\")) printf(\"QSC KEM activating: \%s\\\n\", oqs_alg_name);/g" /root/openssl/ssl/statem/extensions_clnt.c
sed -i "s/if (OQS_SIG_verify(/if (getenv(\"OQSINTERNALS\")) printf(\"QSC signature verifying: %s\\\n\", get_oqs_alg_name(oqs_key->nid));\n    if (OQS_SIG_verify(/g" crypto/ec/oqs_meth.c

cd /root/openssl && make && make install

export CURL_VERSION="7.66.0"

cd /root/curl-${CURL_VERSION}
CPPFLAGS="-I/opt/oqssa/include" \
        LDFLAGS=-Wl,-R/opt/oqssa/lib ./configure --prefix=/opt/oqssa \
                    --enable-debug \
                    --with-ssl=/opt/oqssa && \
    sed -i 's/EVP_MD_CTX_create/EVP_MD_CTX_new/g; s/EVP_MD_CTX_destroy/EVP_MD_CTX_free/g' lib/vtls/openssl.c && \
    make && make install;

cd /root/haproxy-master && make PREFIX="/opt/oqssa" LDFLAGS="-Wl,-rpath,/opt/oqssa/lib" SSL_INC=/opt/oqssa/include SSL_LIB=/opt/oqssa/lib TARGET=linux-glibc USE_OPENSSL=1 && make PREFIX="/opt/oqssa" install

