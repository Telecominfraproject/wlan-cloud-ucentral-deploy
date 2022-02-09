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
| `owprov.configProperties."openwifi\.kafka\.enable"` | string | Configures OpenWIFI Provisioning to use Kafka for communication | `'true'` |
| `owprov.configProperties."openwifi\.kafka\.brokerlist"` | string | Sets up Kafka broker list for OpenWIFI Provisioning to the predictable Kubernetes service name (see `kafka.fullnameOverride` option description for details) | `'kafka:9092'` |
| `rttys.enabled` | boolean | Enables [rttys](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw-rtty) deployment | `True` |
| `rttys.config.token` | string | Sets default rttys token |  |
| `kafka.enabled` | boolean | Enables [kafka](https://github.com/bitnami/charts/blob/master/bitnami/kafka/) deployment | `True` |
| `kafka.fullnameOverride` | string | Overrides Kafka Kubernetes service name so it could be predictable and set in microservices configs | `'kafka'` |
| `kafka.image.registry` | string | Kafka Docker image registry | `'docker.io'` |
| `kafka.image.repository` | string | Kafka Docker image repository | `'bitnami/kafka'` |
| `kafka.image.tag` | string | Kafka Docker image tag | `'2.8.0-debian-10-r43'` |
| `kafka.minBrokerId` | number | Sets Kafka minimal broker ID (useful for multi-node Kafka installations) | `100` |
| `clustersysteminfo.enabled` | boolean | Enables post-install check that makes sure that all services are working correctly using systeminfo RESTAPI method | `false` |
| `clustersysteminfo.delay` | integer | Number of seconds to delay clustersysteminfo execution | `0` |
| `clustersysteminfo.public_env_variables` | hash | Map of public environment variables that will be passed to the script (required for configuration) |  |
| `clustersysteminfo.secret_env_variables` | hash | Map of secret environment variables that will be passed to the script (for example, password) |  |
| `clustersysteminfo.activeDeadlineSeconds` | integer | Number of seconds that are allowed for job to run before failing with Dealine Exceeded error | `2400` |
| `clustersysteminfo.backoffLimit` | integer | Number of jobs retries before job failure | `5` |
| `owls.enabled` | boolean | Install OpenWIFI Load Simulator in the release | `false` |
| `owls.configProperties."openwifi\.kafka\.enable"` | string | Configures OpenWIFI Load Simulator to use Kafka for communication | `'true'` |
| `owls.configProperties."openwifi\.kafka\.brokerlist"` | string | Sets up Kafka broker list for OpenWIFI Load Simulator to the predictable Kubernetes service name (see `kafka.fullnameOverride` option description for details) | `'kafka:9092'` |
| `owlsui.enabled` | boolean | Install OpenWIFI Load Simulator Web UI in the release | `false` |
| `haproxy.enabled` | boolean | Install HAproxy as a unified TCP proxy for services | `true` |
| `haproxy.replicaCount` | Integer | Amount of HAproxy pods to start | `3` |
| `restapiCerts.enabled` | boolean | Enable generation of self-signed certificates for REST API private endpoints (see details below) | `false` |
| `restapiCerts.services` | array | List of services that require certificates generation |  |
| `restapiCerts.clusterDomain` | string | Kubernetes cluster domain | `cluster.local` |

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

## Optional features

Some features of the SDK are not enabled by default, but you may enable them by changing your values file. Below you may find information about supported features and values that may be used as a base to enable these changes. As an example of used values you may check values files in [wlan-testing](https://github.com/Telecominfraproject/wlan-testing/tree/master/helm/ucentral) repository that are used for different automated testing pipelines.

If you want to enable different features, you may try passing additional values files using `-f` flag during `helm install/upgrade` commands.

### Cluster systeminfo check

By setting `clusterinfo.enabled` to `true` you may enable job on post-install/post-upgrade step that will do the following:

1. Change default security credentials from credentials set in OWSEC configuration file (see 'Required password changing on the first startup' block above)
2. Check if all services started responding correctly after the deployment using systeminfo REST API method

In order to do that, you need to additionaly set multiple parameters:

1. clusterinfo.public_env_variables.OWSEC - OWSEC endpoint to use for CLI tools
2. clusterinfo.secret_env_variables.OWSEC_DEFAULT_USERNAME - username used for CLI requests (see OWSEC configuration file for details)
3. clusterinfo.secret_env_variables.OWSEC_DEFAULT_PASSWORD - default password stored in OWSEC configuration that is required for initial password change
4. clusterinfo.secret_env_variables.OWSEC_NEW_PASSWORD - new password that should be set instead of default OWSEC password. It is set only once, then used all the time. Password must comply https://github.com/Telecominfraproject/wlan-cloud-ucentralsec/#authenticationvalidationexpression

If you are interested in script itself, see [script](https://github.com/Telecominfraproject/wlan-cloud-ucentral-deploy/blob/main/chart/docker/clustersysteminfo).

You may see example values to enable this feature in [values.enable-clustersysteminfo.yaml](./feature-values/values.enable-clustersysteminfo.yaml).

### Load simulation

Chart also allows to install [OWLS](https://github.com/Telecominfraproject/wlan-cloud-owls) and [OWLS-UI](https://github.com/Telecominfraproject/wlan-cloud-owls-ui) alongside your installation if you are interested in load testing your installation. See services repositories for available options and configuration details.

You may see example values to enable this feature in [values.enable-owls.yaml](./feature-values/values.enable-owls.yaml).

### HAproxy

In order to use single point of entry for all services (may be used for one cloud Load Balancer per installation) HAproxy is installed by default with other services. HAproxy is working in TCP proxy mode, so every TLS certificate is managed by services themself, while it is possible to pass requests from cloud load balancer to services using same ports (configuration of cloud load balancer may vary from cloud provider to provider).

By default this option is enabled, but you may disable it and make per-service LoadBalancer using values in [values.disable-haproxy.yaml](./feature-values/values.disable-haproxy.yaml).

### OWGW unsafe sysctls

By default Linux is using quite adeqate sysctl values for TCP keepalive, but OWGW may keep disconnected APs in stuck state preventing it from connecting back. This may be changed by setting some sysctls to lower values:

- net.ipv4.tcp_keepalive_intvl
- net.ipv4.tcp_keepalive_probes - 2
- net.ipv4.tcp_keepalive_time - 45

However this change is [not considered safe by Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/#enabling-unsafe-sysctls) and it requires to pass additional argument to your Kubelets services in your Kubernetes cluster:

```
--allowed-unsafe-sysctls net.ipv4.tcp_keepalive_intvl,net.ipv4.tcp_keepalive_probes,net.ipv4.tcp_keepalive_time
```

After this change you may pass additional parameters to OWGW helm chart. You may see example values in [values.owgw-unsafe-sysctl.yaml](./feature-values/values.owgw-unsafe-sysctl.yaml)

### Private REST API cert-manager managed certificates

All services have 2 REST API endpoints - private and public one. Private endpoint is used for inter-service communication and should not be exposed to the world, but since it also requires TLS in order to work correctly, additional optional logic was implemented that allows to manage TLS certificates for such endpoints to be managed by [cert-manager](https://github.com/jetstack/cert-manager). In order to activate this feature following steps are required:

0. Install and configure [cert-manager](https://cert-manager.io/docs/) in your cluster
1. Enable option by setting `restapiCerts.enabled`
2. If you have a different Kubernetes cluster domain, adapt `restapiCerts.clusterDomain` to your cluster domain
3. Add additional parameters for services in order to mount certificates secrets in pods, use certificates by service and add public environment variable that will add cert-manager managed CA certificate to pod's trusted chain (see [OWGW docker-entrypoint.sh](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw/blob/master/docker-entrypoint.sh) as example of how it is done)

You may see example values to enable this feature in [values.restapi-certmanager-certs.yaml](./feature-values/values.restapi-certmanager-certs.yaml).

## Environment specific values

This repository contains values files that may be used in the same manner as feature values above to deploy to specific runtime envionemnts (including different cloud deployments).

Some environments are using [external-dns](https://github.com/kubernetes-sigs/external-dns) service to dynamically set DNS records, but you may manage your records manually

### AWS EKS

EKS based installation assumes that you are using [AWS Load Balancer controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller) so that all required ALBs and NLBs are created automatically. Also it is assumed that you have Route53 managed DNS zone and you've issued wildcard certificate for one of your zones that may be used by Load Balancers.

You may see example values for this environment in [values.aws.yaml](./environment-values/values.aws.yaml).
