#!/usr/bin/env bash
set -e

SERVICES="ucentralgw ucentralsec ucentralfms"

for i in $SERVICES; do
    docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml --env-file .env.selfsigned exec -T $i apk add ca-certificates
    docker cp certs/restapi-ca.pem ucentral_$i\_1:/usr/local/share/ca-certificates/
    docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml --env-file .env.selfsigned exec -T $i update-ca-certificates
done
