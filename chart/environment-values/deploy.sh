#!/bin/bash
set -e

# Usage function
function usage()
{
    cat <<-EOF >&2

This script is indended for OpenWIFI Cloud SDK deployment to TIP QA/Dev environments using assembly Helm chart (https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy/tree/main/chart) with configuration through environment variables

Required environment variables:
- NAMESPACE - namespace suffix that will used added for the Kubernetes environment (i.e. if you pass 'test', kubernetes namespace will be named 'ucentral-test')
- DEPLOY_METHOD - deployment method for the chart deployment (supported methods - 'git' (will use helm-git from assembly chart), 'bundle' (will use chart stored in the Artifactory) or local
- CHART_VERSION - version of chart to be deployed from assembly chart (for 'git' method git ref may be passed, for 'bundle' method version of chart may be passed)
- VALUES_FILE_LOCATION - path to file with override values that may be used for deployment
- DOMAIN - Domain name. default: cicd.lab.wlan.tip.build
- OWGW_AUTH_USERNAME - username to be used for requests to OpenWIFI Security
- OWGW_AUTH_PASSWORD - hashed password for OpenWIFI Security (details on this may be found in https://github.com/Telecominfraproject/wlan-cloud-ucentralsec/#authenticationdefaultpassword)
- OWFMS_S3_SECRET - secret key that is used for OpenWIFI Firmware access to firmwares S3 bucket
- OWFMS_S3_KEY - access key that is used for OpenWIFI Firmware access to firmwares S3 bucket
- OWSEC_NEW_PASSWORD - password that should be set to default user instead of default password from properties
- CERT_LOCATION - path to certificate in PEM format that will be used for securing all endpoint in all services
- KEY_LOCATION - path to private key in PEM format that will be used for securing all endpoint in all services

The following environmnet variables may be passed, but will be ignored if CHART_VERSION is set to release (i.e. v2.4.0):
- OWGW_VERSION - OpenWIFI Gateway version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWGWUI_VERSION - OpenWIFI Web UI version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWSEC_VERSION - OpenWIFI Security version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWFMS_VERSION - OpenWIFI Firmware version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWPROV_VERSION - OpenWIFI Provisioning version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWPROVUI_VERSION - OpenWIFI Provisioning Web UI version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWANALYTICS_VERSION - OpenWIFI Analytics version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWSUB_VERSION - OpenWIFI Subscription (Userportal) version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)
- OWRRM_VERSION - OpenWIFI radio resource management service (RRM) version to deploy (will be used for Docker image tag and git branch for Helm chart if git deployment is required)

Optional environment variables:
- EXTRA_VALUES - extra values that should be passed to Helm deployment separated by comma (,)
- DEVICE_CERT_LOCATION - path to certificate in PEM format that will be used for load simulator
- DEVICE_KEY_LOCATION - path to private key in PEM format that will be used for load simulator
- USE_SEPARATE_OWGW_LB - flag that should change split external DNS for OWGW and other services
- INTERNAL_RESTAPI_ENDPOINT_SCHEMA - what schema to use for internal RESTAPI endpoints (https by default)
- IPTOCOUNTRY_IPINFO_TOKEN - token that should be set for IPInfo support (owgw/owprov iptocountry.ipinfo.token properties), ommited if not passed
- MAILER_USERNAME - SMTP username used for OWSEC mailer
- MAILER_PASSWORD - SMTP password used for OWSEC mailer (only if both MAILER_PASSWORD and MAILER_USERNAME are set, mailer will be enabled)
EOF
}

# Global variables
VALUES_FILE_LOCATION_SPLITTED=()
EXTRA_VALUES_SPLITTED=()

# Helper functions
function check_if_chart_version_is_release()
{
    [[ "$CHART_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]
}

# Check if required environment variables were passed
## Deployment specifics
[ -z ${DEPLOY_METHOD+x} ] && echo "DEPLOY_METHOD is unset" >&2 && usage && exit 1
[ -z ${CHART_VERSION+x} ] && echo "CHART_VERSION is unset" >&2 && usage && exit 1
if [[ "$DEPLOY_METHOD" != "local" ]] ; then
    if check_if_chart_version_is_release ; then
        echo "Chart version ($CHART_VERSION) is a release version, ignoring services versions"
    else
        echo "Chart version ($CHART_VERSION) is not a release version, checking if services versions are set"
        [ -z ${OWGW_VERSION+x} ] && echo "OWGW_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWGWUI_VERSION+x} ] && echo "OWGWUI_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWSEC_VERSION+x} ] && echo "OWSEC_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWFMS_VERSION+x} ] && echo "OWFMS_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWPROV_VERSION+x} ] && echo "OWPROV_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWPROVUI_VERSION+x} ] && echo "OWPROVUI_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWANALYTICS_VERSION+x} ] && echo "OWANALYTICS_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWSUB_VERSION+x} ] && echo "OWSUB_VERSION is unset" >&2 && usage && exit 1
        [ -z ${OWRRM_VERSION+x} ] && echo "OWRRM_VERSION is unset" >&2 && usage && exit 1
    fi
fi
## Environment specifics
[ -z ${NAMESPACE+x} ] && echo "NAMESPACE is unset" >&2 && usage && exit 1
## Variables specifics
[ -z ${VALUES_FILE_LOCATION+x} ] && echo "VALUES_FILE_LOCATION is unset" >&2 && usage && exit 1
[ -z ${OWGW_AUTH_USERNAME+x} ] && echo "OWGW_AUTH_USERNAME is unset" >&2 && usage && exit 1
[ -z ${OWGW_AUTH_PASSWORD+x} ] && echo "OWGW_AUTH_PASSWORD is unset" >&2 && usage && exit 1
[ -z ${OWFMS_S3_SECRET+x} ] && echo "OWFMS_S3_SECRET is unset" >&2 && usage && exit 1
[ -z ${OWFMS_S3_KEY+x} ] && echo "OWFMS_S3_KEY is unset" >&2 && usage && exit 1
[ -z ${OWSEC_NEW_PASSWORD+x} ] && echo "OWSEC_NEW_PASSWORD is unset" >&2 && usage && exit 1
[ -z ${CERT_LOCATION+x} ] && echo "CERT_LOCATION is unset" >&2 && usage && exit 1
[ -z ${KEY_LOCATION+x} ] && echo "KEY_LOCATION is unset" >&2 && usage && exit 1

[ -z ${DEVICE_CERT_LOCATION+x} ] && echo "DEVICE_CERT_LOCATION is unset, setting it to CERT_LOCATION" && export DEVICE_CERT_LOCATION=$CERT_LOCATION
[ -z ${DEVICE_KEY_LOCATION+x} ] && echo "DEVICE_KEY_LOCATION is unset, setting it to KEY_LOCATION" && export DEVICE_KEY_LOCATION=$KEY_LOCATION
[ -z ${INTERNAL_RESTAPI_ENDPOINT_SCHEMA+x} ] && echo "INTERNAL_RESTAPI_ENDPOINT_SCHEMA is unset, setting it to 'https'" && export INTERNAL_RESTAPI_ENDPOINT_SCHEMA=https
export MAILER_ENABLED="false"
[ ! -z ${MAILER_USERNAME+x} ] && [ ! -z ${MAILER_PASSWORD+x} ] && echo "MAILER_USERNAME and MAILER_PASSWORD are set, mailer will be enabled" && export MAILER_ENABLED="true"
[ -z "${DOMAIN}" ] && echo "DOMAIN is unset, using cicd.lab.wlan.tip.build" && export DOMAIN="cicd.lab.wlan.tip.build"

# Transform some environment variables
export OWGW_VERSION_TAG=$(echo ${OWGW_VERSION} | tr '/' '-')
export OWGWUI_VERSION_TAG=$(echo ${OWGWUI_VERSION} | tr '/' '-')
export OWSEC_VERSION_TAG=$(echo ${OWSEC_VERSION} | tr '/' '-')
export OWFMS_VERSION_TAG=$(echo ${OWFMS_VERSION} | tr '/' '-')
export OWPROV_VERSION_TAG=$(echo ${OWPROV_VERSION} | tr '/' '-')
export OWPROVUI_VERSION_TAG=$(echo ${OWPROVUI_VERSION} | tr '/' '-')
export OWANALYTICS_VERSION_TAG=$(echo ${OWANALYTICS_VERSION} | tr '/' '-')
export OWSUB_VERSION_TAG=$(echo ${OWSUB_VERSION} | tr '/' '-')
export OWRRM_VERSION_TAG=$(echo ${OWRRM_VERSION} | tr '/' '-')

# Check deployment method that's required for this environment
helm plugin install https://github.com/databus23/helm-diff || true
if [[ "$DEPLOY_METHOD" == "git" ]] ; then
    helm plugin install https://github.com/aslafy-z/helm-git --version 0.10.0 || true
    rm -rf wlan-cloud-ucentral-deploy || true
    git clone https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy.git
    cd wlan-cloud-ucentral-deploy
    git checkout $CHART_VERSION
    cd chart
    if ! check_if_chart_version_is_release ; then
        sed -i '/wlan-cloud-ucentralgw@/s/ref=.*/ref='${OWGW_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-ucentralgw-ui@/s/ref=.*/ref='${OWGWUI_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-ucentralsec@/s/ref=.*/ref='${OWSEC_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-ucentralfms@/s/ref=.*/ref='${OWFMS_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-owprov@/s/ref=.*/ref='${OWPROV_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-owprov-ui@/s/ref=.*/ref='${OWPROVUI_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-analytics@/s/ref=.*/ref='${OWANALYTICS_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-userportal@/s/ref=.*/ref='${OWSUB_VERSION}'\"/g' Chart.yaml
        sed -i '/wlan-cloud-rrm@/s/ref=.*/ref='${OWRRM_VERSION}'\"/g' Chart.yaml
    fi
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    [ -z "$SKIP_DEPS" ] && helm dependency update
    cd ../..
    export DEPLOY_SOURCE="wlan-cloud-ucentral-deploy/chart"
elif [[ "$DEPLOY_METHOD" == "bundle" ]] ; then
    helm repo add tip-wlan-cloud-ucentral-helm https://tip.jfrog.io/artifactory/tip-wlan-cloud-ucentral-helm/ || true
    export DEPLOY_SOURCE="tip-wlan-cloud-ucentral-helm/openwifi --version $CHART_VERSION"
elif [[ "$DEPLOY_METHOD" == "local" ]] ; then
    export DEPLOY_SOURCE=".."
    pushd ..
    [ -z "$SKIP_DEPS" ] && helm dependency update
    popd
else
    echo "Deploy method is not correct: $DEPLOY_METHOD. Valid values: git, bundle or local" >&2
    exit 1
fi

VALUES_FILES_FLAGS=()
IFS=',' read -ra VALUES_FILE_LOCATION_SPLITTED <<< "$VALUES_FILE_LOCATION"
for VALUE_FILE in ${VALUES_FILE_LOCATION_SPLITTED[*]}; do
    VALUES_FILES_FLAGS+=("-f" $VALUE_FILE)
done
EXTRA_VALUES_FLAGS=()
IFS=',' read -ra EXTRA_VALUES_SPLITTED <<< "$EXTRA_VALUES"
for EXTRA_VALUE in ${EXTRA_VALUES_SPLITTED[*]}; do
    EXTRA_VALUES_FLAGS+=("--set" $EXTRA_VALUE)
done

if [[ "$USE_SEPARATE_OWGW_LB" == "true" ]] ; then
  export HAPROXY_SERVICE_DNS_RECORDS="sec-${NAMESPACE}.${DOMAIN},fms-${NAMESPACE}.${DOMAIN},prov-${NAMESPACE}.${DOMAIN},analytics-${NAMESPACE}.${DOMAIN},sub-${NAMESPACE}.${DOMAIN}"
  export OWGW_SERVICE_DNS_RECORDS="gw-${NAMESPACE}.${DOMAIN}"
else
  export HAPROXY_SERVICE_DNS_RECORDS="gw-${NAMESPACE}.${DOMAIN},sec-${NAMESPACE}.${DOMAIN},fms-${NAMESPACE}.${DOMAIN},prov-${NAMESPACE}.${DOMAIN},analytics-${NAMESPACE}.${DOMAIN},sub-${NAMESPACE}.${DOMAIN}"
  export OWGW_SERVICE_DNS_RECORDS=""
fi

envsubst < values.custom.tpl.yaml > values.custom-${NAMESPACE}.yaml

set -x
helm upgrade --install --create-namespace --wait --timeout 60m \
  --namespace openwifi-${NAMESPACE} \
  ${VALUES_FILES_FLAGS[*]} \
  ${EXTRA_VALUES_FLAGS[*]} \
  -f values.custom-${NAMESPACE}.yaml \
  --set-file owgw.certs."restapi-cert\.pem"=$CERT_LOCATION \
  --set-file owgw.certs."restapi-key\.pem"=$KEY_LOCATION \
  --set-file owgw.certs."websocket-cert\.pem"=$CERT_LOCATION \
  --set-file owgw.certs."websocket-key\.pem"=$KEY_LOCATION \
  --set-file owsec.certs."restapi-cert\.pem"=$CERT_LOCATION \
  --set-file owsec.certs."restapi-key\.pem"=$KEY_LOCATION \
  --set-file owfms.certs."restapi-cert\.pem"=$CERT_LOCATION \
  --set-file owfms.certs."restapi-key\.pem"=$KEY_LOCATION \
  --set-file owprov.certs."restapi-cert\.pem"=$CERT_LOCATION \
  --set-file owprov.certs."restapi-key\.pem"=$KEY_LOCATION \
  --set-file owls.certs."restapi-cert\.pem"=$CERT_LOCATION \
  --set-file owls.certs."restapi-key\.pem"=$KEY_LOCATION \
  --set-file owls.certs."device-cert\.pem"=$DEVICE_CERT_LOCATION \
  --set-file owls.certs."device-key\.pem"=$DEVICE_KEY_LOCATION \
  --set-file owanalytics.certs."restapi-cert\.pem"=$CERT_LOCATION \
  --set-file owanalytics.certs."restapi-key\.pem"=$KEY_LOCATION \
  --set-file owsub.certs."restapi-cert\.pem"=$CERT_LOCATION \
  --set-file owsub.certs."restapi-key\.pem"=$KEY_LOCATION \
  tip-openwifi $DEPLOY_SOURCE
