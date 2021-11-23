# Docker Compose
### Overview
With the provided Docker Compose files you can instantiate a deployment of the OpenWifi microservices and related components. The repository contains a self-signed certificate and a TIP-signed gateway certificate which are valid for the `*.wlan.local` domain. You also have the possibility to either generate and use Letsencrypt certs or provide your own certificates. Furthermore the deployments are split by whether Traefik is used as a reverse proxy/load balancer in front of the microservices or if they are exposed directly on the host. The advantage of using the deployments with Traefik is that you can use Letsencrypt certs (automatic certificate generation and renewal) and you have the ability to scale specific containers to multiple replicas.
- [Non-LB deployment with self-signed certificates](#non-lb-deployment-with-self-signed-certificates)
- [Non-LB deployment with own certificates](#non-lb-deployment-with-own-certificates)
- [LB deployment with self-signed certificates](#lb-deployment-with-self-signed-certificates)
- [LB deployment with Letsencrypt certificates](#lb-deployment-with-letsencrypt-certificates)
### Configuration
If you don't bind mount your own config files they are generated on every startup based on the environment variables in the microservice specific env files. For an overview of the supported configuration properties have a look into the microservice specific env files. For an explanation of the configuration properties please see the README in the respective microservice repository.  
Be aware that the non-LB deployment exposes the generated config files on the host. So if you want to make configuration changes afterwards, please do them directly in the config files located in the microservice data directories.
#### Required password changing on the first startup
One important action that must be done before using the deployment is changing password for the default user in owsec as described in [owsec docs](https://github.com/Telecominfraproject/wlan-cloud-ucentralsec/tree/main#changing-default-password). Please use these docs to find the actions that must be done **after** the deployment in order to start using your deployment.
### Ports
Every OpenWifi service is exposed via a separate port either directly on the host or through Traefik. For an overview of the exposed ports have a look into the deployment specific Docker Compose file. If you use your own certificates or make use of the [Letsencrypt LB deployment](#lb-deployment-with-letsencrypt-certificates), you can also configure different hostnames for the microservices.  
Please note that the OWProv-UI is exposed on port `8080(HTTP)/8443(HTTPS)` by default except for the Letsencrypt LB deployment, where the service listens on the default `80/443` HTTP(S) ports.
## Non-LB deployment with self-signed certificates
1. Switch into the project directory with `cd docker-compose/`.
2. Add an entry for `openwifi.wlan.local` in your hosts file which points to `127.0.0.1` or whatever the IP of the host running the deployment is.
3. Spin up the deployment with `docker-compose up -d`.
4. Check if the containers are up and running with `docker-compose ps`.
5. Add SSL certificate exceptions in your browser by visiting https://openwifi.wlan.local:16001, https://openwifi.wlan.local:16002, https://openwifi.wlan.local:16004 and https://openwifi.wlan.local:16005.
6. Connect to your AP via SSH and add a static hosts entry in `/etc/hosts` for `openwifi.wlan.local`. This should point to the address of the host the Compose deployment runs on.
7. Navigate to the UI `https://openwifi.wlan.local` and login with your OWSec authentication data.
8. To use the curl test scripts included in the microservice repositories set the following environment variables:
```
export UCENTRALSEC="openwifi.wlan.local:16001"
export FLAGS="-s --cacert <your-wlan-cloud-ucentral-deploy-location>/docker-compose/certs/restapi-ca.pem"
```
⚠️**Note**: When deploying with self-signed certificates you can not make use of the trace functionality in the UI since the AP will throw a TLS error when uploading the trace to OWGW. Please use the Letsencrypt deployment or provide your own valid certificates if you want to use this function.
## Non-LB deployment with own certificates
1. Switch into the project directory with `cd docker-compose/`. Copy your websocket and REST API certificates into the `certs/` directory. Make sure to reference the certificates accordingly in the service config if you use different file names or if you want to use different certificates for the respective microservices.
2. Adapt the following hostname and URI variables according to your environment:
### .env
| Variable                   | Description                                                         |
| -------------------------- | ------------------------------------------------------------------- |
| `INTERNAL_OWGW_HOSTNAME`   | Set this to your OWGW hostname, for example `owgw.example.com`.     |
| `INTERNAL_OWSEC_HOSTNAME`  | Set this to your OWSec hostname, for example `owsec.example.com`.   |
| `INTERNAL_OWFMS_HOSTNAME`  | Set this to your OWFms hostname, for example `owfms.example.com`.   |
| `INTERNAL_OWPROV_HOSTNAME` | Set this to your OWProv hostname, for example `owprov.example.com`. |
### owgw.env
| Variable                                 | Description                                                                         |
| ---------------------------------------- | ----------------------------------------------------------------------------------- |
| `FILEUPLOADER_HOST_NAME`                 | Set this to your OWGW fileupload hostname, for example `owgw.example.com`.          |
| `FILEUPLOADER_URI`                       | Set this to your OWGW fileupload URL, for example `https://owgw.example.com:16003`. |
| `SYSTEM_URI_PRIVATE`,`SYSTEM_URI_PUBLIC` | Set this to your OWGW REST API URL, for example `https://owgw.example.com:16002`.   |
| `RTTY_SERVER`                            | Set this to your RTTY server hostname, for example `rttys.example.com`.             |
| `SYSTEM_URI_UI`                          | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.            |
### owgw-ui.env
| Variable                  | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
| `DEFAULT_UCENTRALSEC_URL` | Set this to your OWSec URL, for example `https://owsec.example.com:16001`. |
### owsec.env
| Variable                                 | Description                                                                         |
| ---------------------------------------- | ----------------------------------------------------------------------------------- |
| `SYSTEM_URI_PRIVATE`,`SYSTEM_URI_PUBLIC` | Set this to your OWSec REST API URL, for example `https://owsec.example.com:16001`. |
| `SYSTEM_URI_UI`                          | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.            |
### owfms.env
| Variable                                 | Description                                                                         |
| ---------------------------------------- | ----------------------------------------------------------------------------------- |
| `SYSTEM_URI_PRIVATE`,`SYSTEM_URI_PUBLIC` | Set this to your OWFms REST API URL, for example `https://owfms.example.com:16004`. |
| `SYSTEM_URI_UI`                          | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.            |
### owprov.env
| Variable                                 | Description                                                                           |
| ---------------------------------------- | ------------------------------------------------------------------------------------- |
| `SYSTEM_URI_PRIVATE`,`SYSTEM_URI_PUBLIC` | Set this to your OWProv REST API URL, for example `https://owprov.example.com:16005`. |
| `SYSTEM_URI_UI`                          | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.              |
### owprov-ui.env
| Variable                  | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
| `DEFAULT_UCENTRALSEC_URL` | Set this to your OWSec URL, for example `https://owsec.example.com:16001`. |
3. Spin up the deployment with `docker-compose up -d`.
4. Check if the containers are up and running with `docker-compose ps`.
5. Navigate to the UI and login with your OWSec authentication data.
## LB deployment with self-signed certificates
Follow the same instructions as for the self-signed deployment without Traefik. The only difference is that you have to spin up the deployment with `docker-compose -f docker-compose.lb.selfsigned.yml --env-file .env.selfsigned up -d`. Make sure to specify the Compose and the according .env file every time you're working with the deployment or create an alias, for example `alias docker-compose-lb-selfsigned="docker-compose -f docker-compose.lb.selfsigned.yml --env-file .env.selfsigned"`. You also have the possibility to scale specific services to a specified number of instances with `docker-compose-lb-selfsigned up -d --scale SERVICE=NUM`, where `SERVICE` is the service name as defined in the Compose file.
## LB deployment with Letsencrypt certificates
For the Letsencrypt challenge to work you need a public IP address. The hostnames which you set for the microservices have to resolve to this IP address to pass the HTTP-01 challenge (https://letsencrypt.org/docs/challenge-types/#http-01-challenge).
1. Switch into the project directory with `cd docker-compose/`.
2. Adapt the following hostname and URI variables according to your environment.
### .env.letsencrypt
| Variable                  | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
| `OWGW_HOSTNAME`           | Set this to your OWGW hostname, for example `owgw.example.com`.            |
| `OWGWUI_HOSTNAME`         | Set this to your OWGW-UI hostname, for example `owgw-ui.example.com`.      |
| `OWGWFILEUPLOAD_HOSTNAME` | Set this to your OWGW fileupload hostname, for example `owgw.example.com`. |
| `OWSEC_HOSTNAME`          | Set this to your OWSec hostname, for example `owsec.example.com`.          |
| `OWFMS_HOSTNAME`          | Set this to your OWFms hostname, for example `owfms.example.com`.          |
| `OWPROV_HOSTNAME`         | Set this to your OWProv hostname, for example `owprov.example.com`.        |
| `OWPROVUI_HOSTNAME`       | Set this to your OWProv-UI hostname, for example `owprov-ui.example.com`.  |
| `RTTYS_HOSTNAME`          | Set this to your RTTYS hostname, for example `rttys.example.com`.          |

### owgw.env
| Variable                 | Description                                                                         |
| -----------------------  | ----------------------------------------------------------------------------------- |
| `FILEUPLOADER_HOST_NAME` | Set this to your OWGW fileupload hostname, for example `owgw.example.com`.          |
| `FILEUPLOADER_URI`       | Set this to your OWGW fileupload URL, for example `https://owgw.example.com:16003`. |
| `SYSTEM_URI_PUBLIC`      | Set this to your OWGW REST API URL, for example `https://owgw.example.com:16002`.   |
| `RTTY_SERVER`            | Set this to your public RTTY server hostname, for example `rttys.example.com`.      |
| `SYSTEM_URI_UI`          | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.            |

### owgw-ui.env
| Variable            | Description                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| `DEFAULT_OWSEC_URL` | Set this to your OWSec URL, for example `https://owsec.example.com:16001`. |

### owsec.env
| Variable            | Description                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| `SYSTEM_URI_PUBLIC` | Set this to your OWSec URL, for example `https://owsec.example.com:16001`. |
| `SYSTEM_URI_UI`     | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.   |

### owfms.env
| Variable            | Description                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| `SYSTEM_URI_PUBLIC` | Set this to your OWFms URL, for example `https://owfms.example.com:16004`. |
| `SYSTEM_URI_UI`     | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.   |
### owprov.env
| Variable             | Description                                                                  |
| -------------------- | ---------------------------------------------------------------------------- |
| `SYSTEM_URI_PUBLIC`  | Set this to your OWProv URL, for example `https://owprov.example.com:16005`. |
| `SYSTEM_URI_UI`      | Set this to your OWGW-UI URL, for example `https://owgw-ui.example.com`.     |
### owprov-ui.env
| Variable                  | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
| `DEFAULT_UCENTRALSEC_URL` | Set this to your OWSec URL, for example `https://owsec.example.com:16001`. |
### traefik.env
| Variable                                            | Description                               |
| --------------------------------------------------- | ----------------------------------------- |
| `TRAEFIK_CERTIFICATESRESOLVERS_OPENWIFI_ACME_EMAIL` | Email address used for ACME registration. |
3. Spin up the deployment with `docker-compose -f docker-compose.lb.letsencrypt.yml --env-file .env.letsencrypt up -d`. Make sure to specify the Compose and the according .env file every time you're working with the deployment or create an alias, for example `alias docker-compose-lb-letsencrypt="docker-compose -f docker-compose.lb.letsencrypt.yml --env-file .env.letsencrypt"`. You also have the possibility to scale specific services to a specified number of instances with `docker-compose-lb-letsencrypt up -d --scale SERVICE=NUM`, where `SERVICE` is the service name as defined in the Compose file.
4. Check if the containers are up and running with `docker-compose-lb-letsencrypt ps`.
5. Navigate to the UI and login with your OWSec authentication data.

**Note**: The deployments create local volumes to persist mostly application, database and certificate data. In addition to that the `certs/` directory is bind mounted into the microservice containers. Be aware that for the bind mounts the host directories and files will be owned by the user in the container. Since the files are under version control, you may have to change the ownership to your user again before pulling changes.
### owsec templates and wwwassets
On the startup of owsec directories for wwwassets and mailer templates are created from the base files included in Docker image. After the initial startup you may edit those files as you wish in the [owsec-data/persist](./owsec-data/persist) directory.
