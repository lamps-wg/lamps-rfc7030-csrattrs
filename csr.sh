#!/bin/bash

openssl req -config csr.cnf -reqexts req_extensions -new -key <(openssl ecparam -genkey -name prime256v1) -subj /CN=test -out csr.pem
echo -e "\nExample CSR including extensionRequest attribute in text form:\n"
openssl req -in csr.pem -noout -text
openssl req -in csr.pem -outform der -out csr.der
echo -e "\nExample CSR including extensionRequest attribute in ASN.1 DER form:\n"
dumpasn1 csr.der
