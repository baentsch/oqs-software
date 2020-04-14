#!/bin/sh

INSTALLDIR=/opt/oqssa
BUILDDIR=/root
HAPROXYDIR=/opt/haproxy

# Do in Dockerfile:
# apt-get update -qq && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y gcc autoconf automake git libssl-dev libtool make unzip wget zlib1g-dev lighttpd

cd $BUILDDIR

git clone --single-branch --branch master https://github.com/open-quantum-safe/liboqs 
git clone --single-branch --branch OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl

# Build & install liboqs
cd $BUILDDIR/liboqs
mkdir build && cd build && cmake ..  -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$BUILDDIR/openssl/oqs && make -j && make install
mkdir build-static && cd build-static && cmake ..  -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=$BUILDDIR/openssl/oqs && make -j && make install

# Build and install openssl-oqs
cd $BUILDDIR/openssl

# Insert usage warning
export GITNAME=`git rev-parse --abbrev-ref HEAD`
export GITREV=`git rev-parse --short HEAD`
sed -i "s/static int stoperrset = 0;/static int stoperrset = 0; if (\!getenv(\"OQSWARNINGDISABLE\")) printf(\"OQS-enabled OpenSSL ($GITNAME, $GITREV) starting. Only for non-productive use. \\\nSee https:\/\/github.com\/open-quantum-safe\/openssl#limitations-and-security\\\n\");/g" ssl/ssl_init.c

# Insert KEM information:
sed -i "s/\/\* initialize the kex \*\//if (getenv(\"OQSINTERNALS\")) printf(\"KEM activating: \%s\\\n\", oqs_alg_name);/g" ssl/statem/extensions_clnt.c

# Insert SigAlg information:
sed -i "s/if (OQS_SIG_verify(/if (getenv(\"OQSINTERNALS\")) printf(\"QSC signature verifying: %s\\\n\", get_oqs_alg_name(oqs_key->nid));\n    if (OQS_SIG_verify(/g" crypto/ec/oqs_meth.c

LDFLAGS="-Wl,-rpath -Wl,$INSTALLDIR/lib" ./Configure linux-x86_64 -lm --prefix=$INSTALLDIR && make && make install
ln -s $INSTALLDIR/lib/liboqs.so.0.0.0 $INSTALLDIR/lib/liboqs.so.0

# build haproxy
cd $BUILDDIR
wget http://www.haproxy.org/download/2.1/src/haproxy-2.1.4.tar.gz  && tar xzvf haproxy-2.1.4.tar.gz

cd haproxy-2.1.4 && make LDFLAGS="-Wl,-rpath,$INSTALLDIR/lib" SSL_INC=$INSTALLDIR/include SSL_LIB=$INSTALLDIR/lib TARGET=linux-glibc USE_OPENSSL=1 && make PREFIX=$INSTALLDIR install

# build curl
cd $BUILDDIR
CURL_VERSION=7.66.0
wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz && tar -zxvf curl-$CURL_VERSION.tar.gz

cd $BUILDDIR/curl-${CURL_VERSION}
# Dynamic build:
CPPFLAGS="-I$INSTALLDIR" \
LDFLAGS=-Wl,-R$INSTALLDIR/lib ./configure --prefix=$INSTALLDIR \
                    --enable-debug \
                    --with-ssl=$INSTALLDIR && \
    make && make install;

# Static build:
#CPPFLAGS="-I/$INSTALLDIR/include" \
#        ./configure --disable-shared --enable-static --prefix=$INSTALLDIR \
#                    --enable-debug \
#                    --with-ssl=$INSTALLDIR && \
#    make V=1 curl_LDFLAGS=-all-static && make install;

echo "export PATH=/opt/oqssa/bin:$PATH" >> /root/.bashrc
