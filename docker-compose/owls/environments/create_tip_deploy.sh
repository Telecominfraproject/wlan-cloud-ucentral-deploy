#!/bin/bash
# Create a deploy directory for a particular environment.
# Only support the letsencrypt setup here!
# Optionally copy it over.

set -e
USAGE="$0 environment"

env="$1"
if [ -z "$env" ] ; then
    echo $USAGE
    exit 1
fi
dir="$env"
dhost=""
if [[ "$env" == "owls1" ]] ; then
    hostname="owls1.lab.wlan.tip.build"
    dhost="tipowlsls"
    destdir="deploy-owls"
elif [[ "$env" == "owls2" ]] ; then
    hostname="owls2.lab.wlan.tip.build"
    dhost="tipowlsgw"
    destdir="deploy-owls"
else
    echo "Unknown environment: $env"
    exit 1
fi

# need newer GNU sed (mac one isn't compatible) [on mac install sed using homebrew]
sed=$(command -v gsed)
[ -z "$sed" ] && sed="sed"

set -x


echo
echo "Make sure you have created/updated the device-cert.pem and device-key.pem files!"
echo
url="https://$hostname"
[ -d "$dir" ] || mkdir "$dir"
cd "$dir"
mkdir -p owls-ui traefik certs/cas || true
cp ../../.env ../../*.env .
cp ../../docker-compose.lb.letsencrypt.yml docker-compose.yml
cp ../../owls-ui/default-lb.conf owls-ui/default.conf
cp ../../traefik/* traefik
cp ../../../certs/cas/* certs/cas 2>/dev/null || true
cp ../../../certs/*.pem certs
echo "SDKHOSTNAME=$hostname" >> .env
$sed -i "s~REACT_APP_UCENTRALSEC_URL=.*~REACT_APP_UCENTRALSEC_URL=$url:16001~" owls-ui.env
$sed -i "s~SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$url:16001~" owsec.env
$sed -i "s~SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$url~" owsec.env
$sed -i "s~SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$url:16004~" owfms.env
$sed -i "s~SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$url~" owfms.env
$sed -i "s~SYSTEM_URI_PUBLIC=.*~SYSTEM_URI_PUBLIC=$url:16007~" owls.env
$sed -i "s~SYSTEM_URI_UI=.*~SYSTEM_URI_UI=$url~" owls.env
$sed -i "s~../certs:~./certs:~" docker-compose.yml


if [[ -n "$dhost" && -n "$destdir" ]] ; then
    rsync -avh --progress ./ $dhost:$destdir
fi
