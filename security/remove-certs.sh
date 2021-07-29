#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $DIR && rm root.crt root.key service.properties credentials truststore.jks

for i in broker operator service
do
    rm $i-signed.crt $i.key $i.csr $i-keypair.pem
done
