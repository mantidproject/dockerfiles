#! /bin/bash

#Install OpenSSL
mkdir -p /OpenSSL
cd /OpenSSL
wget https://www.openssl.org/source/openssl-3.1.0.tar.gz --no-check-certificate
zcat openssl-3.1.0.tar.gz | tar xf -
cd openssl-3.1.0
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared
make
make install
