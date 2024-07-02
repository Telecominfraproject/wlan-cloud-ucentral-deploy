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
helm plugin install https://github.com/jkroepke/helm-secrets
```

## Configuration

_helmfile.yaml_ contains the configuration for all the environments. External values files are used for secrets or where appropriate. Each environment needs to be created in this file before it can be deployed.  The files in ./secrets/ are encrypted with SOPS. Use `helm secrets edit secrets/FILE` to edit.

## Installation

To install the entire stack: `helm --environment ENVNAME apply`.
To install just cgw: `helm --environment ENVNAME -l app=cgw apply`.
To install just cgw with a specific image tag: `helm --environment ENVNAME -l app=cgw apply --state-values-set "cgw.tag=latest"`.

## Removal

To remove the entire stack: `helm --environment ENVNAME delete`.
To remove just cgw: `helm --environment ENVNAME -l app=cgw delete`.
Delete the namespace manually if it is no longer required.

# Re-installation

Note that the kafka, postgres and redis charts do not want to be reinstalled so will have to be removed and installed. If you wish to upgrade these then you must follow the respective Bitnami instructions on how to upgrade these charts.
