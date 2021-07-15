# Docker Compose
With the provided Docker Compose file you can instantiate a complete deployment of the uCentral microservices and related components for local development purposes. To spin up a local development environment:
1. Switch into the project directory with `cd docker-compose/`.
2. This repository contains a gateway certificate signed by TIP and a self-signed certificate for the REST API and other components which are used by default in the Compose deployment. The certificates are valid for the `*.wlan.local` domain and the Docker Compose uCentral microservice configs use `ucentral.wlan.local` as a hostname, so make sure you add an entry in your hosts file (or in your local DNS solution) which points to `127.0.0.1`.
3. If you have your own certificates and want to use the deployment for anything other than local development copy your certs into the `certs/` directory and reference them in the appropriate sections of the microservice configuration files. Make sure to also adapt the sections which reference the hostname. For more information on certificates please see the [certificates section](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw#certificates) of this README and/or [CERTIFICATES.md](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw/blob/master/CERTIFICATES.md).
4. Docker Compose pulls the microservice images from the JFrog repository. If you want to change the image tag or some of the image versions which are used for the other services, have a look into the `.env` file. You'll also find service specific `.env` files in this directory. Edit them if you want to change database passwords (highly recommended!) or other configuration data. Don't forget to adapt your changes in the application configuration files.
5. Open `docker-compose/ucentralgw-data/ucentral.properties` to change [authentication data](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw#default-username-and-password) for uCentralGW (again highly recommended!).
6. Spin up the deployment with `docker-compose up -d`.
7. Add the self-signed certificates to the system trust store of the containers with `./add-ca-cert.sh`.
8. Navigate to the UI which listens to `127.0.0.1` or `ucentral.wlan.local` and login with your uCentralGW authentication data.
9. To use the [curl test script](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw/blob/main/TEST_CURL.md) to talk to the API set the following environment variables:
```
export UCENTRALSEC="ucentral.wlan.local:16001"
export FLAGS="-s --cacert $YOUR_WLAN-CLOUD-UCENTRAL-DEPLOY_LOCATION/certs/restapi-ca.pem"
```
The `--cacert` option is necessary since the REST API certificates are self-signed. Omit the option if you provide your own signed certificates.

PS: The Docker Compose deployment creates five local volumes to persist mostly database data and data for Zookeeper and Kafka. If you want re-create the deployment and remove all persistent application and database data just delete the volumes with `docker volume rm $(docker volume ls -qf name=ucentral)` after you stopped the services with `docker-compose down`.
