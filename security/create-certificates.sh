#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

root_cert=root.crt
root_key=root.key
password=password

echo $password > credentials

if [ ! -f "$root_cert" ]; then
    echo "Create a root certificate"
    openssl req \
    -x509 \
    -days 9999 \
    -newkey rsa:2048 \
    -keyout $root_key \
    -out $root_cert \
    -subj '/CN=root.omo.systems/OU=OMO/O=OMO/L=O/C=NO' \
    -passin pass:$password \
    -passout pass:$password
fi

for i in service operator broker
do
  echo "Create a certificate for $i"
  ./create-pem-certificate.sh $i
  echo
done

rm *.srl

echo "Create a truststore"

keytool -import \
  -noprompt \
  -keystore truststore.jks \
  -alias root-ca \
  -file $root_cert \
  -storepass $password \
  -keypass $password

echo
echo "Create service.properties that uses PEM files"
cat <<EOF > service.properties
security.protocol=SSL
ssl.keystore.type=PEM
ssl.keystore.location=$DIR/service-keypair.pem
ssl.truststore.type=PEM
ssl.truststore.location=$DIR/$root_cert
EOF
