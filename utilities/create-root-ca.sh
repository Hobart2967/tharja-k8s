#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <common-name>"
    exit 1
fi

mkdir -p cert
openssl genrsa -out cert/rootCA.key 4096
openssl req -x509 -new -nodes -key cert/rootCA.key -sha256 -days 1024 -subj "/CN=acme-pebble.sys-acme.svc.cluster.local" \
  -reqexts v3_req -extensions v3_ca \
  -out cert/rootCA.crt -config root-ca-crt.conf

cat > cert/pebble-san.cnf <<EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[ dn ]
CN = acme-pebble.sys-acme.svc.cluster.local

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = acme-pebble.sys-acme.svc.cluster.local
DNS.2 = acme-pebble.sys-acme.svc
DNS.3 = acme-pebble.sys-acme
DNS.4 = acme-pebble
EOF

openssl genrsa -out cert/pebble.key 4096
openssl req -new -key cert/pebble.key -out cert/pebble.csr -config cert/pebble-san.cnf

cat > cert/pebble-ext.cnf <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names

[alt_names]
DNS.1=acme-pebble.sys-acme.svc.cluster.local
DNS.2=acme-pebble.sys-acme.svc
DNS.3=acme-pebble.sys-acme
DNS.4=acme-pebble
EOF

openssl x509 -req -in cert/pebble.csr -CA cert/rootCA.crt -CAkey cert/rootCA.key -CAcreateserial -out cert/pebble.crt -days 825 -sha256 -extfile cert/pebble-ext.cnf
openssl x509 -in cert/pebble.crt -noout -text | grep -A2 "Subject Alternative Name"