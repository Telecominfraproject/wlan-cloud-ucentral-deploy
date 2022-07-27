#!/bin/bash
set -e

# Usage function
usage () {
  echo;
  echo "This script is intended for OpenWiFi cloud SDK deployment using Docker Compose (https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy/tree/main/docker-compose). Configuration is done based on shell environment variables.";
  echo;
  echo "Required environment variables:"
  echo;
  echo "- DEFAULT_UCENTRALSEC_URL - public URL of the OWSec service"
  echo "- SYSTEM_URI_UI - public URL of the OWGW-UI service"
  echo;
#  echo "- INTERNAL_OWGW_HOSTNAME - OWGW microservice hostname for Docker internal communication"
#  echo "- INTERNAL_OWSEC_HOSTNAME - OWSec microservice hostname for Docker internal communication"
#  echo "- INTERNAL_OWFMS_HOSTNAME - OWFms microservice hostname for Docker internal communication"
#  echo "- INTERNAL_OWPROV_HOSTNAME - OWProv microservice hostname for Docker internal communication"
#  echo "- INTERNAL_OWANALYTICS_HOSTNAME - OWAnalytics microservice hostname for Docker internal communication"
#  echo "- INTERNAL_OWSUB_HOSTNAME - OWSub microservice hostname for Docker internal communication"
#  echo;
  echo "- OWGW_FILEUPLOADER_HOST_NAME - hostname to be used for OWGW fileupload";
  echo "- OWGW_FILEUPLOADER_URI - URL to be used for OWGW fileupload";
#  echo "- OWGW_SYSTEM_URI_PRIVATE - private URL to be used for OWGW";
  echo "- OWGW_SYSTEM_URI_PUBLIC - public URL to be used for OWGW";
  echo "- OWGW_RTTY_SERVER - public hostname of the RTTY server";
  echo;
#  echo "- OWSEC_SYSTEM_URI_PRIVATE - private URL to be used for OWSec";
  echo "- OWSEC_SYSTEM_URI_PUBLIC - public URL to be used for OWSec";
  echo;
#  echo "- OWFMS_SYSTEM_URI_PRIVATE - private URL to be used for OWFms";
  echo "- OWFMS_SYSTEM_URI_PUBLIC - public URL to be used for OWFms";
  echo;
#  echo "- OWPROV_SYSTEM_URI_PRIVATE - private URL to be used for OWProv";
  echo "- OWPROV_SYSTEM_URI_PUBLIC - public URL to be used for OWProv";
  echo;
#  echo "- OWANALYTICS_SYSTEM_URI_PRIVATE - private URL to be used for OWAnalytics";
  echo "- OWANALYTICS_SYSTEM_URI_PUBLIC - public URL to be used for OWAnalytics";
  echo;
#  echo "- OWSUB_SYSTEM_URI_PRIVATE - private URL to be used for OWSub";
  echo "- OWSUB_SYSTEM_URI_PUBLIC - public URL to be used for OWSub";
  echo;
  echo "- OWRRM_SERVICECONFIG_PRIVATEENDPOINT - private URL to be used for OWRRM";
  echo "- OWRRM_SERVICECONFIG_PUBLICENDPOINT - public URL to be used for OWRRM";
  echo;
  echo "Optional environment variables:"
  echo "- WEBSOCKET_CERT - Your Digicert-signed websocket certificate"
  echo "- WEBSOCKET_KEY - The key to your Digicert-signed websocket certificate"
  echo;
  echo "- OWSEC_AUTHENTICATION_DEFAULT_USERNAME - username to be used for requests to OWSec";
  echo "- OWSEC_AUTHENTICATION_DEFAULT_PASSWORD - hashed password for OWSec (details on this may be found in https://github.com/Telecominfraproject/wlan-cloud-ucentralsec/#authenticationdefaultpassword)";
  echo;
  echo "- OWFMS_S3_SECRET - secret key that is used for OWFms access to firmwares S3 bucket";
  echo "- OWFMS_S3_KEY - access key that is used for OWFms access to firmwares S3 bucket";
  echo;
  echo "- SDKHOSTNAME - Public hostname which is used for cert generation when using the Letsencrypt deployment method"
  echo "- TRAEFIK_ACME_EMAIL - Email address used for ACME registration"
}

# Check if required environment variables were passed
## Configuration variables applying to multiple microservices
[ -z ${DEFAULT_UCENTRALSEC_URL+x} ] && echo "DEFAULT_UCENTRALSEC_URL is unset" && usage && exit 1
[ -z ${SYSTEM_URI_UI+x} ] && echo "SYSTEM_URI_UI is unset" && usage && exit 1
## Internal microservice hostnames
#[ -z ${INTERNAL_OWGW_HOSTNAME+x} ] && echo "INTERNAL_OWGW_HOSTNAME is unset" && usage && exit 1
#[ -z ${INTERNAL_OWSEC_HOSTNAME+x} ] && echo "INTERNAL_OWSEC_HOSTNAME is unset" && usage && exit 1
#[ -z ${INTERNAL_OWFMS_HOSTNAME+x} ] && echo "INTERNAL_OWFMS_HOSTNAME is unset" && usage && exit 1
#[ -z ${INTERNAL_OWPROV_HOSTNAME+x} ] && echo "INTERNAL_OWPROV_HOSTNAME is unset" && usage && exit 1
#[ -z ${INTERNAL_OWANALYTICS_HOSTNAME+x} ] && echo "INTERNAL_OWANALYTICS_HOSTNAME is unset" && usage && exit 1
#[ -z ${INTERNAL_OWSUB_HOSTNAME+x} ] && echo "INTERNAL_OWSUB_HOSTNAME is unset" && usage && exit 1
## OWGW configuration variables
[ -z ${OWGW_FILEUPLOADER_HOST_NAME+x} ] && echo "OWGW_FILEUPLOADER_HOST_NAME is unset" && usage && exit 1
[ -z ${OWGW_FILEUPLOADER_URI+x} ] && echo "OWGW_FILEUPLOADER_URI is unset" && usage && exit 1
#[ -z ${OWGW_SYSTEM_URI_PRIVATE+x} ] && echo "OWGW_SYSTEM_URI_PRIVATE is unset" && usage && exit 1
[ -z ${OWGW_SYSTEM_URI_PUBLIC+x} ] && echo "OWGW_SYSTEM_URI_PUBLIC is unset" && usage && exit 1
[ -z ${OWGW_RTTY_SERVER+x} ] && echo "OWGW_RTTY_SERVER is unset" && usage && exit 1
## OWSec configuration variables
#[ -z ${OWSEC_SYSTEM_URI_PRIVATE+x} ] && echo "OWSEC_SYSTEM_URI_PRIVATE is unset" && usage && exit 1
[ -z ${OWSEC_SYSTEM_URI_PUBLIC+x} ] && echo "OWSEC_SYSTEM_URI_PUBLIC is unset" && usage && exit 1
## OWFms configuration variables
#[ -z ${OWFMS_SYSTEM_URI_PRIVATE+x} ] && echo "OWFMS_SYSTEM_URI_PRIVATE is unset" && usage && exit 1
[ -z ${OWFMS_SYSTEM_URI_PUBLIC+x} ] && echo "OWFMS_SYSTEM_URI_PUBLIC is unset" && usage && exit 1
## OWProv configuration variables
#[ -z ${OWPROV_SYSTEM_URI_PRIVATE+x} ] && echo "OWPROV_SYSTEM_URI_PRIVATE is unset" && usage && exit 1
[ -z ${OWPROV_SYSTEM_URI_PUBLIC+x} ] && echo "OWPROV_SYSTEM_URI_PUBLIC is unset" && usage && exit 1
## OWAnalytics configuration variables
#[ -z ${OWANALYTICS_SYSTEM_URI_PRIVATE+x} ] && echo "OWANALYTICS_SYSTEM_URI_PRIVATE is unset" && usage && exit 1
[ -z ${OWANALYTICS_SYSTEM_URI_PUBLIC+x} ] && echo "OWANALYTICS_SYSTEM_URI_PUBLIC is unset" && usage && exit 1
## OWSub configuration variables
#[ -z ${OWSUB_SYSTEM_URI_PRIVATE+x} ] && echo "OWSUB_SYSTEM_URI_PRIVATE is unset" && usage && exit 1
[ -z ${OWSUB_SYSTEM_URI_PUBLIC+x} ] && echo "OWSUB_SYSTEM_URI_PUBLIC is unset" && usage && exit 1
## OWRRM configuration variables
[ -z ${OWRRM_SERVICECONFIG_PRIVATEENDPOINT+x} ] && echo "OWRRM_SERVICECONFIG_PRIVATEENDPOINT is unset" && usage && exit 1
[ -z ${OWRRM_SERVICECONFIG_PUBLICENDPOINT+x} ] && echo "OWRRM_SERVICECONFIG_PUBLICENDPOINT is unset" && usage && exit 1

# Search and replace image version tags if set
if [[ ! -z "$OWGW_VERSION" ]]; then
  sed -i "s~.*OWGW_TAG=.*~OWGW_TAG=$OWGW_VERSION~" .env
fi
if [[ ! -z "$OWSEC_VERSION" ]]; then
  sed -i "s~.*OWSEC_TAG=.*~OWSEC_TAG=$OWSEC_VERSION~" .env
fi
if [[ ! -z "$OWFMS_VERSION" ]]; then
  sed -i "s~.*OWFMS_TAG=.*~OWFMS_TAG=$OWFMS_VERSION~" .env
fi
if [[ ! -z "$OWPROV_VERSION" ]]; then
  sed -i "s~.*OWPROV_TAG=.*~OWPROV_TAG=$OWPROV_VERSION~" .env
fi
if [[ ! -z "$OWANALYTICS_VERSION" ]]; then
  sed -i "s~.*OWANALYTICS_TAG=.*~OWANALYTICS_TAG=$OWANALYTICS_VERSION~" .env
fi
if [[ ! -z "$OWSUB_VERSION" ]]; then
  sed -i "s~.*OWSUB_TAG=.*~OWSUB_TAG=$OWSUB_VERSION~" .env
fi

# Search and replace variable values in env files
#sed -i "s~\(^INTERNAL_OWGW_HOSTNAME=\).*~\1$INTERNAL_OWGW_HOSTNAME~" .env
#sed -i "s~\(^INTERNAL_OWSEC_HOSTNAME=\).*~\1$INTERNAL_OWSEC_HOSTNAME~" .env
#sed -i "s~\(^INTERNAL_OWFMS_HOSTNAME=\).*~\1$INTERNAL_OWFMS_HOSTNAME~" .env
#sed -i "s~\(^INTERNAL_OWPROV_HOSTNAME=\).*~\1$INTERNAL_OWPROV_HOSTNAME~" .env
#sed -i "s~\(^INTERNAL_OWANALYTICS_HOSTNAME=\).*~\1$INTERNAL_OWANALYTICS_HOSTNAME~" .env
#sed -i "s~\(^INTERNAL_OWSUB_HOSTNAME=\).*~\1$INTERNAL_OWSUB_HOSTNAME~" .env

if [[ ! -z "$SDKHOSTNAME" ]]; then
  sed -i "s~.*SDKHOSTNAME=.*~SDKHOSTNAME=$SDKHOSTNAME~" .env.letsencrypt
fi

if [[ ! -z "$WEBSOCKET_CERT" ]]; then
  echo "$WEBSOCKET_CERT" > certs/websocket-cert.pem
fi
if [[ ! -z "$WEBSOCKET_KEY" ]]; then
  echo "$WEBSOCKET_KEY" > certs/websocket-key.pem && chmod 600 certs/websocket-key.pem
fi

sed -i "s~.*FILEUPLOADER_HOST_NAME=.*~FILEUPLOADER_HOST_NAME=$OWGW_FILEUPLOADER_HOST_NAME~" owgw.env
sed -i "s~.*FILEUPLOADER_URI=.*~FILEUPLOADER_URI=$OWGW_FILEUPLOADER_URI~" owgw.env
sed -i "s~.*SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$OWGW_SYSTEM_URI_PUBLIC~" owgw.env
#sed -i "s~.*SYSTEM_URI_PRIVATE=.*~SYSTEM_URI_PRIVATE=$OWGW_SYSTEM_URI_PRIVATE~" owgw.env
sed -i "s~.*SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$SYSTEM_URI_UI~" owgw.env
sed -i "s~.*RTTY_SERVER=.*~RTTY_SERVER=$OWGW_RTTY_SERVER~" owgw.env

if [[ ! -z "$SIMULATORID" ]]; then
  sed -i "s~.*SIMULATORID=.*~SIMULATORID=$SIMULATORID~" owgw.env
fi

sed -i "s~.*DEFAULT_UCENTRALSEC_URL=.*~DEFAULT_UCENTRALSEC_URL=$DEFAULT_UCENTRALSEC_URL~" owgw-ui.env

if [[ ! -z "$OWSEC_AUTHENTICATION_DEFAULT_USERNAME" ]]; then
  sed -i "s~.*AUTHENTICATION_DEFAULT_USERNAME=.*~AUTHENTICATION_DEFAULT_USERNAME=$OWSEC_AUTHENTICATION_DEFAULT_USERNAME~" owsec.env
fi
if [[ ! -z "$OWSEC_AUTHENTICATION_DEFAULT_PASSWORD" ]]; then
  sed -i "s~.*AUTHENTICATION_DEFAULT_PASSWORD=.*~AUTHENTICATION_DEFAULT_PASSWORD=$OWSEC_AUTHENTICATION_DEFAULT_PASSWORD~" owsec.env
fi
#sed -i "s~.*SYSTEM_URI_PRIVATE=.*~SYSTEM_URI_PRIVATE=$OWSEC_SYSTEM_URI_PRIVATE~" owsec.env
sed -i "s~.*SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$OWSEC_SYSTEM_URI_PUBLIC~" owsec.env
sed -i "s~.*SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$SYSTEM_URI_UI~" owsec.env

#sed -i "s~.*SYSTEM_URI_PRIVATE=.*~SYSTEM_URI_PRIVATE=$OWFMS_SYSTEM_URI_PRIVATE~" owfms.env
sed -i "s~.*SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$OWFMS_SYSTEM_URI_PUBLIC~" owfms.env
sed -i "s~.*SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$SYSTEM_URI_UI~" owfms.env
if [[ ! -z "$OWFMS_S3_SECRET" ]]; then
  sed -i "s~.*S3_SECRET=.*~S3_SECRET=$OWFMS_S3_SECRET~" owfms.env
fi
if [[ ! -z "$OWFMS_S3_KEY" ]]; then
  sed -i "s~.*S3_KEY=.*~S3_KEY=$OWFMS_S3_KEY~" owfms.env
fi

#sed -i "s~.*SYSTEM_URI_PRIVATE=.*~SYSTEM_URI_PRIVATE=$OWPROV_SYSTEM_URI_PRIVATE~" owprov.env
sed -i "s~.*SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$OWPROV_SYSTEM_URI_PUBLIC~" owprov.env
sed -i "s~.*SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$SYSTEM_URI_UI~" owprov.env

sed -i "s~.*REACT_APP_UCENTRALSEC_URL=.*~REACT_APP_UCENTRALSEC_URL=$DEFAULT_UCENTRALSEC_URL~" owprov-ui.env

#sed -i "s~.*SYSTEM_URI_PRIVATE=.*~SYSTEM_URI_PRIVATE=$OWANALYTICS_SYSTEM_URI_PRIVATE~" owanalytics.env
sed -i "s~.*SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$OWANALYTICS_SYSTEM_URI_PUBLIC~" owanalytics.env
sed -i "s~.*SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$SYSTEM_URI_UI~" owanalytics.env

#sed -i "s~.*SYSTEM_URI_PRIVATE=.*~SYSTEM_URI_PRIVATE=$OWSUB_SYSTEM_URI_PRIVATE~" owsub.env
sed -i "s~.*SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$OWSUB_SYSTEM_URI_PUBLIC~" owsub.env
sed -i "s~.*SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$SYSTEM_URI_UI~" owsub.env

sed -i "s~.*SERVICECONFIG_PRIVATEENDPOINT=.*~SERVICECONFIG_PRIVATEENDPOINT=$OWRRM_SERVICECONFIG_PRIVATEENDPOINT~" owrrm.env
sed -i "s~.*SERVICECONFIG_PUBLICENDPOINT=.*~SERVICECONFIG_PUBLICENDPOINT=$OWRRM_SERVICECONFIG_PUBLICENDPOINT~" owrrm.env

if [[ ! -z "$TRAEFIK_ACME_EMAIL" ]]; then
  sed -i "s~.*TRAEFIK_CERTIFICATESRESOLVERS_OPENWIFI_ACME_EMAIL=.*~TRAEFIK_CERTIFICATESRESOLVERS_OPENWIFI_ACME_EMAIL=$TRAEFIK_ACME_EMAIL~" traefik.env
fi

# Run the deployment
if [[ ! -z "$SDKHOSTNAME" ]]; then
  docker-compose -f docker-compose.lb.letsencrypt.yml --env-file .env.letsencrypt up -d
else
  docker-compose up -d
fi
