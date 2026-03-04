# PKI 2.0 Upgrade

## Reference Cluster (QA01) and Deployment updates
- Updated QA01 and DEV01 deployments to use new QA Insta Chain certificates - 2026/03
- Removed digicert chain certificates - 2025/12/16
- Added support for insta only chain certificates - 2025/09/23
- Added Insta chain certificates - 2025/08/12

## Checklist when upgrading or installing a new OpenWiFi Cloud SDK
For PKI 2.0 support we will need to:
- [ ] Upgrade to the latest version of the OpenWiFi Cloud SDK.
- [ ] Switch to using the Insta certificates for the server certificate when all APs are updated to 4.1.0+.

### Upgrade OpenWiFi Cloud SDK
The latest version of the OpenWiFi Cloud SDK is available at https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy/tree/main. This is also the location for this README.PKI2.0.md file.

### Docker Compose
The file `docker-compose/certs/clientcas.pem` already contains the Insta chain certificates.

**Do this only once all APs have been upgraded to support PKI2.0**:
Request your server certificate package using the [OpenLAN PKI tools Cert Client](https://github.com/Telecominfraproject/openlan-pki-tools/tree/main/cert_client).
Once you receive your server certificate package, please update the `websocket-cert.pem` and `websocket-key.pem` files in the `docker-compose/certs` directory.
Restart the SDK by running the appropriate `docker-compose` command: `./dco stop && ./dco start`.

Once the switch-over to Insta is complete, TIP will update the `docker-compose/certs/cert.pem` and `key.pem` files to contain the Insta versions of the `*.wlan.local` certificate. This is only a concern if you are using *wlan.local* has your host name. The Digicert chain certificates will also be removed at this time.

## Advanced

## Checklist when updating an existing deployment (4.0.0+)
If you have a recent 4.0.0 based deployment already running.
- [ ] Phase 1: Switch to using the Insta chain certificates (still allowing non PKI 2.0 devices).
- [ ] Update 2 SDK components.
- [ ] Phase 2: Switch to using the Insta certificates and remove the digicert chain certificates when all APs are updated to 4.1.1+.

### Phase 1: Switch to using the Insta chain certificates (and accept non PKI 2.0 devices)

#### Docker Compose
The file `docker-compose/certs/clientcas_digicert.pem` contains the Insta chain certificates (along with the previous Digicert ones.) This file needs to be updated locally. Please use this file instead of `clientcas.pem` if you still wish to support PKI1.0 devices.

#### Kubernetes
The file `charts/environment-values/values.openwifi-qa.yaml` under `clientcas.pem` already contains the Insta chain certificates. Please make sure that this file gets updated in any existing deployments. It should be reflected in the `owgw-certs` secret under `clientcas.pem`.

### Update 2 SDK components
Make sure the image for OWGW is `tip-tip-wlan-cloud-ucentral.jfrog.io/owgw:master` or a specific tag like `v4.2.0` (when version 4.2.0 is released.)
Use `tip-tip-wlan-cloud-ucentral.jfrog.io/owgwui:main` for owgwui.

#### Docker Compose
Change your .env file to set the tags (use the release tag once available `v4.2.0`):
```bash
OWGW_TAG=master
OWGWUI_TAG=main
```
Restart the stack by running the appropriate `docker-compose` command: `./dco relaunch`.

#### Kubernetes
If you are already running the 'main' version of the SDK, you can delete the owgw and owgw-ui pods and a new version should be retrieved. Otherwise change your deployment to switch to the images specified above, either by editing your deployments directly or upgrading the 2 respective helm charts of owgw to master owgw-ui to main (or *v4.1.0* release tag when available.)

### Phase 2: Switch to using the Insta only chain certificates
*Do this only once all APs have been upgraded to support PKI2.0!*

Request your server certificate package using the [OpenLAN PKI tools Cert Client](https://github.com/Telecominfraproject/openlan-pki-tools/tree/main/cert_client).

#### Docker Compose
The file `docker-compose/certs/clientcas.pem` contains the Insta chain certificates only. This file needs to be updated locally. Please use this file to replace your copy of `clientcas.pem`.
Once you receive your server certificate package, please update the `websocket-cert.pem` and `websocket-key.pem` secrets in the `docker-compose/certs` directory.
Restart the stack by running the appropriate `docker-compose` command: `./dco relaunch`.

#### Kubernetes
The file `charts/environment-values/values.openwifi-qa-insta.yaml` under `clientcas.pem` already contains the Insta chain certificates. Please make sure that this file gets updated in any existing deployments. It should be reflected in the `owgw-certs` secret under `clientcas.pem`.

Make sure you update the certificate and key referred to as `websocket-cert` and `websocket-key` in the `owgw-certs` secret. This is done by setting the following helm variables:
- owgw.certs."websocket-cert\\.pem"
- owgw.certs."websocket-key\\.pem"
If you are making a change to the secret then a GW restart is also required (by deleting the owgw pod.)
