#!/bin/sh

set -e

primitive_service_dir="$1"

cd "$primitive_service_dir"
mkdir certs && cd certs
openssl req -new -newkey rsa:4096 -x509 -days 365000 -nodes -out server.crt -keyout server.key -batch
