#! /bin/bash

#Install OpenSSL
mkdir -p /OpenSSL
cd /OpenSSL
wget https://www.openssl.org/source/openssl-1.1.1t.tar.gz --no-check-certificate
zcat openssl-1.1.1t.tar.gz | tar xf -
cd openssl-1.1.1t
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared
make
make install
