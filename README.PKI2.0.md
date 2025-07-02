# PKI 2.0 Upgrade

## Overview
For PKI 2.0 we will need to:
- Add Insta chain certificates to the list of trusted certificates.
- Switch to using the Insta certifcates for the server certificate.

## Docker Compose
The file `certs/clientcas.pem` already contains the Insta Chain certificates (along with the previous Digicert ones.)
Once you receive your server certificate package from Insta, please update the `websocket-cert.pem` and `websocket-key.pem` files.
Restart the stack by running the appropriate `docker-compose` command.

## Kubernetes
The file `charts/environment-values/values.openwifi-qa.yaml` under `clientcas.pem` already contains the Insta Chain certificates (along with the previous Digicert ones.) Please make sure that this file gets updated in any existing deployments. It should be reflected in the `owgw-certs` secret under `clientcas.pem`.
Once you receive your server certificate package from Insta, please update the `websocket-cert.pem` and `websocket-key.pem` secrets in the same location. If you are making a change to the secret then a GW restart is also required (by deleting the owgw pod.)
Make sure the image for OWGW is `tip-tip-wlan-cloud-ucentral.jfrog.io/owgw:master` or a specific tag like `v4.1.0` (when version 4.1.0 is released.)
