# ucentralgw

This Helm chart helps to deploy uCentral with all required dependencies to the Kubernetes clusters. Purpose of this chart is to setup correct connections between other microservices and other dependencies with correct Values and other charts as dependencies in [chart definition](Chart.yaml)

## TL;DR;

[helm-git](https://github.com/aslafy-z/helm-git) is required for remote the installation as it pull charts from other repositories for the deployment, so intall it if you don't have it already.

```bash
$ helm install .
```

## Introduction

This chart bootstraps an uCentral on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

Current dependencies may be found in [chart definition](Chart.yaml) and list will be extended when new services will be introduced.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release git+https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy/@chart?ref=main
```

The command deploys ucentralgw on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that will be overwritten above default values from dependent charts.

> **Tip**: List all releases using `helm list`

If you need to update your release, it could be required to update your helm charts dependencies before installation:

```bash
helm dependency update
```

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
| `ucentralgw.configProperties."ucentral\.kafka\.enable"` | string | Configures uCentralGW to use Kafka for communication | `'true'` |
| `ucentralgw.configProperties."ucentral\.kafka\.brokerlist"` | string | Sets up Kafka broker list for uCentralGW to the predictable Kubernetes service name (see `kafka.fullnameOverride` option description for details) | `'kafka:9092'` |
| `ucentralsec.configProperties."ucentral\.kafka\.enable"` | string | Configures uCentralSec to use Kafka for communication | `'true'` |
| `ucentralsec.configProperties."ucentral\.kafka\.brokerlist"` | string | Sets up Kafka broker list for uCentralSec to the predictable Kubernetes service name (see `kafka.fullnameOverride` option description for details) | `'kafka:9092'` |
| `rttys.enabled` | boolean | Enables [rttys](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw-rtty) deployment | `True` |
| `rttys.config.token` | string | Sets default rttys token |  |
| `kafka.enabled` | boolean | Enables [kafka](https://github.com/bitnami/charts/blob/master/bitnami/kafka/) deployment | `True` |
| `kafka.fullnameOverride` | string | Overrides Kafka Kubernetes service name so it could be predictable and set in microservices configs | `'kafka'` |
| `kafka.image.registry` | string | Kafka Docker image registry | `'docker.io'` |
| `kafka.image.repository` | string | Kafka Docker image repository | `'bitnami/kafka'` |
| `kafka.image.tag` | string | Kafka Docker image tag | `'2.8.0-debian-10-r43'` |
| `kafka.minBrokerId` | number | Sets Kafka minimal broker ID (useful for multi-node Kafka installations) | `100` |
| `ucentralgwui.enabled` | boolean | Enables [uCentralGW-UI](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw-ui) deployment | `True` |

If required, further overrides may be passed. They will be merged with default values from this chart and other subcharts with priority to values you'll pass.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set ucentralgw.replicaCount=1 \
    .
```

The above command sets that only 1 instance of ucentralgw to be running

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml .
```

> **Tip**: You can use the default [values.yaml](values.yaml) as a base for customization.
