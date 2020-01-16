FROM openqsafe/ci-alpine

WORKDIR /root

RUN git clone --single-branch --branch master https://github.com/open-quantum-safe/liboqs && \
    git clone --single-branch --branch OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl

ENV CURL_VERSION 7.66.0
RUN wget https://github.com/haproxy/haproxy/archive/master.zip && unzip master.zip  && wget https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz && tar -zxvf curl-${CURL_VERSION}.tar.gz;


WORKDIR /root/liboqs
RUN autoreconf -i && \
    ./configure --prefix=/root/openssl/oqs && \
    make && \
    make install;

WORKDIR /root/openssl
#RUN ./config shared --prefix=/opt/oqssa && CNF_LDFLAGS="-Wl,-rpath -Wl,/opt/oqssa/lib" make 
RUN LDFLAGS="-Wl,-rpath -Wl,/opt/oqssa/lib" ./Configure linux-x86_64 -lm --prefix=/opt/oqssa && cat Makefile && make 

ADD install.sh /root/install.sh

CMD ["/bin/sh"]
