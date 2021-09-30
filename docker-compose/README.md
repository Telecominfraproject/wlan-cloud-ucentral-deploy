# Docker Compose
With the provided Docker Compose file you can instantiate a complete deployment of the uCentral microservices and related components for local development purposes. To spin up a local development environment:
1. Switch into the project directory with `cd docker-compose/`.
2. This repository contains a gateway certificate signed by TIP and a self-signed certificate for the REST API and other components which are used by default in the Compose deployment. The certificates are valid for the `*.wlan.local` domain and the Docker Compose uCentral microservice configs use `ucentral.wlan.local` as a hostname, so make sure you add an entry in your hosts file (or in your local DNS solution) which points to `127.0.0.1` or whatever the IP of the host running the deployment is. Be aware that by default only port `15002` (websocket) and `16003` (fileupload) are exposed on all interfaces and the rest only on localhost. Make sure to adapt that according to your needs.
3. If you have your own certificates and want to use the deployment for anything other than local development copy your certs into the `certs/` directory and reference them in the appropriate sections of the microservice configuration files. Make sure to also adapt the sections which reference the hostname. For more information on certificates please see the [certificates section](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw#certificates) of this README and/or [CERTIFICATES.md](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw/blob/master/CERTIFICATES.md).
4. Docker Compose pulls the microservice images from the JFrog repository. If you want to change the image tag or some of the image versions which are used for the other services, have a look into the `.env` file. You'll also find service specific `.env` files in this directory. Edit them if you want to change database passwords (highly recommended!) or other configuration data. Don't forget to adapt your changes in the application configuration files.
5. Open `docker-compose/ucentralgw-data/ucentralgw.properties` to change [authentication data](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw#default-username-and-password) for uCentralGW (again highly recommended!).
6. Spin up the deployment with `docker-compose up -d`.
7. Add the self-signed certificates to the system trust store of the containers with `./add-ca-cert.sh`.
8. Add SSL certificate exceptions in your browser by visiting https://ucentral.wlan.local:16001, https://ucentral.wlan.local:16002 and https://ucentral.wlan.local:16004 (make sure to visit all and add the exceptions).
9. Connect to your AP via SSH and add a static hosts entry in `/etc/hosts` for `ucentral.wlan.local` which points to the address of the host the Compose deployment runs on.
10. Navigate to the UI `http://ucentral.wlan.local` and login with your uCentralGW authentication data.
11. To use the [curl test script](https://github.com/Telecominfraproject/wlan-cloud-ucentralgw/blob/main/TEST_CURL.md) to talk to the API set the following environment variables:
```
export UCENTRALSEC="ucentral.wlan.local:16001"
export FLAGS="-s --cacert <your-wlan-cloud-ucentral-deploy-location>/docker-compose/certs/restapi-ca.pem"
```
The `--cacert` option is necessary since the REST API certificates are self-signed. Omit the option if you provide your own signed certificates.

**Note**: When deploying with self-signed certificates you can not make use of the trace functionality in the UI since the AP will throw a TLS error when uploading the trace to uCentralGW. Please use the Letsencrypt deployment or provide your own valid certificates if you want to use this function.

PS: The deployment creates local volumes to persist mostly application and database data. In addition to that several bind mounts are created: one for the `docker-compose/certs/` directory which is used by multiple services, and the other ones mount service specific data directories and configuration files located under `docker-compose/` into the appropriate containers. Be aware that for the bind mounts the host directories and files will be owned by the user in the container. Since the files are under version control, you may have to change the ownership to your user again before pulling changes.
