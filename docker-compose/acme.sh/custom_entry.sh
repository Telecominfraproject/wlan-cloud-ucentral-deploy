#!/bin/sh

UCENTRALGW_HOSTNAMES="$UCENTRALGW_HOSTNAME $INTERNAL_UCENTRALGW_HOSTNAME"
UCENTRALSEC_HOSTNAMES="$UCENTRALSEC_HOSTNAME $INTERNAL_UCENTRALSEC_HOSTNAME"
UCENTRALFMS_HOSTNAMES="$UCENTRALFMS_HOSTNAME $INTERNAL_UCENTRALFMS_HOSTNAME"

if [ ! -d /acme.sh/ca ]; then
    echo "First deployment, issuing certificates."
    acme.sh --set-default-ca --server letsencrypt

    for hostname in $UCENTRALGW_HOSTNAMES; do
        acme.sh --issue -d "$hostname" --cert-home /acme.sh/ucentralgw_certs --cert-file /acme.sh/ucentralgw_certs/"$hostname"/restapi-cert.pem --key-file /acme.sh/ucentralgw_certs/"$hostname"/restapi-key.pem --ca-file /acme.sh/ucentralgw_certs/"$hostname"/restapi-ca.pem -w /acme.sh/letsencrypt
    done

    for hostname in $UCENTRALSEC_HOSTNAMES; do
        acme.sh --issue -d "$hostname" --cert-home /acme.sh/ucentralsec_certs --cert-file /acme.sh/ucentralsec_certs/"$hostname"/restapi-cert.pem --key-file /acme.sh/ucentralsec_certs/"$hostname"/restapi-key.pem --ca-file /acme.sh/ucentralsec_certs/"$hostname"/restapi-ca.pem -w /acme.sh/letsencrypt
    done

    for hostname in $UCENTRALFMS_HOSTNAMES; do
        acme.sh --issue -d "$hostname" --cert-home /acme.sh/ucentralfms_certs --cert-file /acme.sh/ucentralfms_certs/"$hostname"/restapi-cert.pem --key-file /acme.sh/ucentralfms_certs/"$hostname"/restapi-key.pem --ca-file /acme.sh/ucentralfms_certs/"$hostname"/restapi-ca.pem -w /acme.sh/letsencrypt
    done

    acme.sh --issue -d "$RTTYS_HOSTNAME" --cert-home /acme.sh/rttys_certs --cert-file /acme.sh/rttys_certs/restapi-cert.pem --key-file /acme.sh/rttys_certs/restapi-key.pem --ca-file /acme.sh/rttys_certs/restapi-ca.pem -w /acme.sh/letsencrypt
fi

echo "Switching into daemon mode."
exec /entry.sh daemon
