# openwifi

This Helm chart helps to deploy OpenWIFI Cloud SDK with all required dependencies to the Kubernetes clusters. Purpose of this chart is to setup correct connections between other microservices and other dependencies with correct Values and other charts as dependencies in [chart definition](Chart.yaml)

## TL;DR;

[helm-git](https://github.com/aslafy-z/helm-git) is required for remote the installation as it pull charts from other repositories for the deployment, so intall it if you don't have it already.

```bash
$ helm dependency update
$ helm install .
```

Then change the default password as described in [owsec docs](https://github.com/Telecominfraproject/wlan-cloud-ucentralsec/tree/main#changing-default-password).

## Introduction

This chart bootstraps the OpenWIFI Cloud SDK on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

Current dependencies may be found in [chart definition](Chart.yaml) and list will be extended when new services will be introduced.

## Installing the Chart

There are multiple ways to install this chart. Described commands will deploy the OpenWIFI Cloud SDK on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that will be overwritten above default values from dependent charts.

### Installation using local git repo

To install the chart from local git repo with the release name `my-release` you need to first update dependencies as it is required with dependencies deployed by helm-git:

```bash
$ helm dependency update
$ helm install .
```

### Installation using remote chart

To install the chart with the release name `my-release` you need to first update dependencies as it is required with dependencies deployed by helm-git:

```bash
$ helm install --name my-release git+https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy@chart/openwifi-0.1.0.tgz?ref=main
```

### Installation using external repo

This approach requires adding external helm repo and new versions are build for every [release](https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy/releases):

```bash
helm repo add tip-wlan https://tip.jfrog.io/artifactory/tip-wlan-cloud-ucentral-helm/
helm install my-release tip-wlan/openwifi
```

## Required password changing on the first startup

One important action that must be done before using the deployment is changing password for the default user in owsec as described in [owsec docs](https://github.com/Telecominfraproject/wlan-cloud-ucentralsec/tree/main#changing-default-password). Please use these docs to find the actions that must be done **after** the deployment in order to start using your deployment.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters that overrides microservice's charts default values to make it deployable out-of-box. In order to get full list of values per-service you should refer to the service helm charts (actual list may be found in [chart definition](Chart.yaml)).

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `owgw.configProperties."openwifi\.kafka\.enable"` | string | Configures OpenWIFI Gateway to use Kafka for communication | `'true'` |
| `owgw.configProperties."openwifi\.kafka\.brokerlist"` | string | Sets up Kafka broker list for OpenWIFI Gateway to the predictable Kubernetes service name (see `kafka.fullnameOverride` option description for details) | `'kafka:9092'` |
| `owsec.configProperties."openwifi\.kafka\.enable"` | string | Configures OpenWIFI Security to use Kafka for communication | `'true'` |
| `owsec.configProperties."openwifi\.kafka\.brokerlist"` | string | Sets up Kafka broker list for OpenWIFI Security to the predictable Kubernetes service name (see `kafka.fullnameOverride` option description for details) | `'kafka:9092'` |
| `owfms.configProperties."openwifi\.kafka\.enable"` | string | Configures OpenWIFI Firmware to use Kafka for communication | `'true'` |
| `owfms.configProperties."openwifi\.kafka\.brokerlist"` | string | Sets up Kafka broker list for OpenWIFI Firmware to the predictable Kubernetes service name (see `kafka.fullnameOverride` option description for details) | `'kafka:9092'` |
| `rttys.enabled` | boolean | Enables [rttys](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw-rtty) deployment | `True` |
| `rttys.config.token` | string | Sets default rttys token |  |
| `kafka.enabled` | boolean | Enables [kafka](https://github.com/bitnami/charts/blob/master/bitnami/kafka/) deployment | `True` |
| `kafka.fullnameOverride` | string | Overrides Kafka Kubernetes service name so it could be predictable and set in microservices configs | `'kafka'` |
| `kafka.image.registry` | string | Kafka Docker image registry | `'docker.io'` |
| `kafka.image.repository` | string | Kafka Docker image repository | `'bitnami/kafka'` |
| `kafka.image.tag` | string | Kafka Docker image tag | `'2.8.0-debian-10-r43'` |
| `kafka.minBrokerId` | number | Sets Kafka minimal broker ID (useful for multi-node Kafka installations) | `100` |

If required, further overrides may be passed. They will be merged with default values from this chart and other subcharts with priority to values you'll pass.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set owgw.replicaCount=1 \
    .
```

The above command sets that only 1 instance of OpenWIFI Gateway to be running

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml .
```

> **Tip**: You can use the default [values.yaml](values.yaml) as a base for customization.
