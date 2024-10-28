#!/bin/sh

set -e

cd /var/lib/primitiveql/data

cp ../certs/* .
chown primitive:primitive server.key
chmod 600 server.key

sed -i "s/^#ssl = off/ssl = on/" primitiveql.conf
sed -i "s/^#ssl_ciphers =.*/ssl_ciphers = 'AES256+EECDH:AES256+EDH'/" primitiveql.conf
