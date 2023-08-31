#!/usr/bin/bash
set -e
# CA
CA_FOLDER=./ca
CA_KEY=$CA_FOLDER/key.pem
CA_CER=$CA_FOLDER/cert.pem
funCGenPrivateKeyAndSign(){
    CA_KEY=$2/key.pem
    CA_CER=$2/cert.pem
    CNF=$1/req.conf
    KEY=$1/key.pem
    CSR=$1/cert.csr
    CER=$1/cert.pem
    EXT=$1/sign.ext
    rm -f $CSR
    rm -f $CER
    rm -f $KEY
    openssl genpkey -algorithm RSA -outform PEM -out $KEY
    openssl req -new -key $KEY -out $CSR -config $CNF
    openssl x509 -req -in  $CSR -CA $CA_CER -CAkey $CA_KEY -CAcreateserial -out $CER -days 365 -extfile $EXT
}
funCGenPrivateKeyAndSign ./nodes/node_65501 ./ca
funCGenPrivateKeyAndSign ./nodes/node_65502 ./ca
