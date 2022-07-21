# wlan-cloud-ucentral-deploy

This Git repository is used for different deployment manifests for [uCentral](https://openwifi.tip.build/v/2.0.0/)

Currently 2 deployment methods are supported:

1. [Helm deployment](chart) - may be used for deployment to Kubernetes clusters
2. [Docker-compose](docker-compose) - may be used for local deployments

Details on every type of deployment may be found in the corresponding directories

## How to cut a new release

This is a short version of [uCentral branching model](https://telecominfraproject.atlassian.net/wiki/spaces/WIFI/pages/1416364078/uCentral+branching+model) doc with specifics for this repo. To cut a new release following steps must be done:

1. Create release branch with next Chart version (check Git tags for the latest version - for example if latest tag was `v0.1.0`, create release branch `release/v0.1.1`), set required microservices tags in refs in Chart.yaml (for example, if we want to have this version to be tied to ucentralgw release version `v2.0.0`, we should set it’s repository to `"git+https://github.com/Telecominfraproject/wlan-cloud-ucentralgw@helm?ref=v2.0.0"`).
2. Increase Helm version in [Chart.yaml](./chart/Chart.yaml) to the same version as Git tag (for example if the latest git tag is `v0.1.0`, set version `0.1.1` (**without v in it**) in Chart.yaml).
3. Also increase the microservice image tags used by the Docker Compose deployments according to the release in the 'Image tags' section of the `docker-compose/.env`, `docker-compose/.env.selfsigned` and `docker-compose/.env.letsencrypt` files.
4. Create new git tag from release branch. The Git tag should have the same name as the intended release version. Once the tag is pushed to the repo, Github will trigger a build process that will create an assembly Helm chart bundle with all version fixed to the release equal to the Git tag name and will publish it to the public Artifactory and as GitHub release asset.
5. Release to the QA namespace using the packaged Helm assembly chart to verify there are no issues related to the deployment.

