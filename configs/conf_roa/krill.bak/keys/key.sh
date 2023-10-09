#!/usr/bin/bash
#set -e
# CA
# generate private key for CA
CA_KEY=./ca/key.pem
CA_CER=./ca/cert.pem
CA_CNF=./ca/ca.conf
rm -f $CA_KEY
rm -f $CA_CER
openssl genrsa -out $CA_KEY 2048
#openssl req -x509 -sha256 -new -nodes -key $CA_KEY -out $CA_CER -days 60 -config $CA_CNF
#openssl req -x509 -sha256 -new -nodes -key $CA_KEY -out $CA_CER -days 60 -config $CA_CNF
./genrsa.sh
cp $CA_CER ./ca/ca.crt
#openssl x509 -in $CA_CER -noout -text
# WEB
WEB_KEY=./web/key.pem
WEB_CSR=./web/cert.csr
WEB_CER=./web/cert.pem
SCR_CNF=./web/req.conf
SNG_EXT=./web/sign.ext
# rm $WEB_KEY
openssl genpkey -algorithm RSA -outform PEM -out $WEB_KEY

# # generate sign request for CA using the private key generated above
openssl req -new -key $WEB_KEY -out $WEB_CSR -config $SCR_CNF
# sign 
openssl x509 -req -in  $WEB_CSR -CA $CA_CER -CAkey $CA_KEY -CAcreateserial -out $WEB_CER -days 1 -extfile $SNG_EXT
# -extfile web/v3.ext 
cp $WEB_CER ./web/web.crt
openssl x509 -in  $WEB_CER -noout -text

# # move the files out
#rm key.pem
#rm cert.pem
#cp $WEB_KEY key.pem
#cp $WEB_CER cert.pem

