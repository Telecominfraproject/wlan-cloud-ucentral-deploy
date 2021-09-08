#!/bin/sh

if [ ! -d /acme.sh/ca ]; then
    echo "First deployment, issuing certificates."
    acme.sh --set-default-ca --server letsencrypt

    acme.sh --issue -d "$UCENTRALGW_HOSTNAME" --cert-home /acme.sh/ucentralgw_certs --cert-file /acme.sh/ucentralgw_certs/restapi-cert.pem --key-file /acme.sh/ucentralgw_certs/restapi-key.pem --ca-file /acme.sh/ucentralgw_certs/restapi-ca.pem -w /acme.sh/letsencrypt

    acme.sh --issue -d "$UCENTRALSEC_HOSTNAME" --cert-home /acme.sh/ucentralsec_certs --cert-file /acme.sh/ucentralsec_certs/restapi-cert.pem --key-file /acme.sh/ucentralsec_certs/restapi-key.pem --ca-file /acme.sh/ucentralsec_certs/restapi-ca.pem -w /acme.sh/letsencrypt

    acme.sh --issue -d "$UCENTRALFMS_HOSTNAME" --cert-home /acme.sh/ucentralfms_certs --cert-file /acme.sh/ucentralfms_certs/restapi-cert.pem --key-file /acme.sh/ucentralfms_certs/restapi-key.pem --ca-file /acme.sh/ucentralfms_certs/restapi-ca.pem -w /acme.sh/letsencrypt

    acme.sh --issue -d "$RTTYS_HOSTNAME" --cert-home /acme.sh/rttys_certs --cert-file /acme.sh/rttys_certs/restapi-cert.pem --key-file /acme.sh/rttys_certs/restapi-key.pem --ca-file /acme.sh/rttys_certs/restapi-ca.pem -w /acme.sh/letsencrypt
fi

echo "Switching into daemon mode."
exec /entry.sh daemon
