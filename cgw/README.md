# CGW Charts

## Pre-requisites

The following binaries are needed:
- [helmfile](https://github.com/helmfile/helmfile/releases/download/v0.165.0/helmfile_0.165.0_linux_amd64.tar.gz)
- helm
- kubectl

The following helm plugins are needed:
```bash
helm plugin install https://github.com/aslafy-z/helm-git --version 0.16.0
helm plugin install https://github.com/databus23/helm-diff
```

## Configuration

_helmfile.yaml_ contains the configuration for all the environments. External values files are used for secrets or where appropriate. Each environment needs to be created in this file before it can be deployed. The _values/certs.device.yaml_ file is generated in github workflows.
This file should contain the device cert and key for the domain you are deploying.
```
certs:
  websocket-cert.pem: 5c0lvd0RRWUpLb1pJa...
  websocket-key.pem: V6WEFqWEhNVFk3RGda...
```
To generate (with the two websocket pem files available):
```
echo "certs:" > values/certs.device.yaml
kubectl create secret generic certs --dry-run=client -o yaml \
    --from-file=websocket-key.pem --from-file=websocket-cert.pem \
    | grep websocket- >> values/certs.device.yaml
```

## Installation

To install the entire stack: `helm --environment ENVNAME apply`.
To install just cgw: `helm --environment ENVNAME -l app=cgw apply`.
To install just cgw with a specific image tag: `helm --environment ENVNAME -l app=cgw apply --state-values-set "cgw.tag=main"`.

## Removal

To remove the entire stack: `helm --environment ENVNAME delete`.
To remove just cgw: `helm --environment ENVNAME -l app=cgw delete`.
Delete the namespace manually if it is no longer required.

# Re-installation

Note that the kafka, postgres and redis charts do not want to be reinstalled so will have to be removed and installed. If you wish to upgrade these then you must follow the respective Bitnami instructions on how to upgrade these charts.
