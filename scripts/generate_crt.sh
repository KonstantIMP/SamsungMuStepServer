#!/bin/bash

CRT_NAME=${1:-mustep}

echo "Generate new certificate $CRT_NAME"

openssl req \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=KonstantIMP/CN=localhost" \
    -config "/etc/ssl/openssl.cnf" \
    -keyout "${CRT_NAME}.key" \
    -out "${CRT_NAME}.crt"

echo "Generated $CRT_NAME.key and $CRT_NAME.crt files in local directory"
