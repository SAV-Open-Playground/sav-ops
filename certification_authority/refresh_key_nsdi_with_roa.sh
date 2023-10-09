#!/usr/bin/bash
set -e
# CA
CA_FOLDER=./ca
CA_KEY=$CA_FOLDER/key.pem
CA_CER=$CA_FOLDER/cert.pem
funCGenPrivateKeyAndSign(){
	CA_KEY=$2/key.pem
	CA_CER=$2/cert.pem
	CNF=$1/../../req.conf
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
echo "start refresh container node_3356 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_3356 ./ca
echo "start refresh container node_34224 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_34224 ./ca
echo "start refresh container node_3549 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_3549 ./ca
echo "start refresh container node_13335 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_13335 ./ca
echo "start refresh container node_3303 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_3303 ./ca
echo "start refresh container node_209 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_209 ./ca
echo "start refresh container node_1299 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_1299 ./ca
echo "start refresh container node_174 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_174 ./ca
echo "start refresh container node_7018 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_7018 ./ca
echo "start refresh container node_2519 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_2519 ./ca
echo "start refresh container node_3257 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_3257 ./ca
echo "start refresh container node_3741 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_3741 ./ca
echo "start refresh container node_2914 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_2914 ./ca
echo "start refresh container node_6762 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_6762 ./ca
echo "start refresh container node_2516 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_2516 ./ca
echo "start refresh container node_38040 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_38040 ./ca
echo "start refresh container node_2152 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_2152 ./ca
echo "start refresh container node_5511 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_5511 ./ca
echo "start refresh container node_293 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_293 ./ca
echo "start refresh container node_4837 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_4837 ./ca
echo "start refresh container node_1273 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_1273 ./ca
echo "start refresh container node_1239 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_1239 ./ca
echo "start refresh container node_6453 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_6453 ./ca
echo "start refresh container node_31133 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_31133 ./ca
echo "start refresh container node_64049 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_64049 ./ca
echo "start refresh container node_6461 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_6461 ./ca
echo "start refresh container node_3491 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_3491 ./ca
echo "start refresh container node_6939 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_6939 ./ca
echo "start refresh container node_9002 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_9002 ./ca
echo "start refresh container node_37100 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_37100 ./ca
echo "start refresh container node_3786 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_3786 ./ca
echo "start refresh container node_5413 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_5413 ./ca
echo "start refresh container node_701 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_701 ./ca
echo "start refresh container node_4134 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_4134 ./ca
echo "start refresh container node_132203 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_132203 ./ca
echo "start refresh container node_4766 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_4766 ./ca
echo "start refresh container node_12552 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_12552 ./ca
echo "start refresh container node_57866 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_57866 ./ca
echo "start refresh container node_16735 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_16735 ./ca
echo "start refresh container node_33891 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_33891 ./ca
echo "start refresh container node_9607 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_9607 ./ca
echo "start refresh container node_55410 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_55410 ./ca
echo "start refresh container node_2497 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_2497 ./ca
echo "start refresh container node_9680 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_9680 ./ca
echo "start refresh container node_4775 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_4775 ./ca
echo "start refresh container node_55644 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_55644 ./ca
echo "start refresh container node_16509 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_16509 ./ca
echo "start refresh container node_18403 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_18403 ./ca
echo "start refresh container node_4809 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_4809 ./ca
echo "start refresh container node_4637 ca"
funCGenPrivateKeyAndSign ./node_nsdi_with_roa/node_4637 ./ca
