# Docker Compose
### Overview
With the provided Docker Compose files you can instantiate a deployment of the OpenWifi microservices and related components. The repository contains a self-signed certificate and a TIP-signed gateway certificate which are valid for the `*.wlan.local` domain. You also have the possibility to either generate and use Letsencrypt certs or provide your own certificates. Furthermore the deployments are split by whether Traefik is used as a reverse proxy/load balancer in front of the microservices or if they are exposed directly on the host. The advantage of using the deployments with Traefik is that you can use Letsencrypt certs (automatic certificate generation and renewal) and you have the ability to scale specific containers to multiple replicas.  
The repository also contains a separate Docker Compose deployment to set up the [OWLS microservice](https://github.com/Telecominfraproject/wlan-cloud-owls) and related components for running a load simulation test against an existing controller.
- [Non-LB deployment with self-signed certificates](#non-lb-deployment-with-self-signed-certificates)
- [Non-LB deployment with own certificates](#non-lb-deployment-with-own-certificates)
- [Non-LB deployment with PostgreSQL](#non-lb-deployment-with-postgresql)
- [LB deployment with self-signed certificates](#lb-deployment-with-self-signed-certificates)
- [LB deployment with Letsencrypt certificates](#lb-deployment-with-letsencrypt-certificates)
- [OWLS deployment with self-signed certificates](#owls-deployment-with-self-signed-certificates)
### Configuration
If you don't bind mount your own config files they are generated on every startup based on the environment variables in the microservice specific env files. For an overview of the supported configuration properties have a look into the microservice specific env files. For an explanation of the configuration properties please see the README in the respective microservice repository.  
Be aware that the non-LB deployment exposes the generated config files on the host. So if you want to make configuration changes afterwards, please do them directly in the config files located in the microservice data directories.
#### Required password changing on the first startup
One important action that must be done before using the deployment is changing password for the default user in owsec as described in [owsec docs](https://github.com/Telecominfraproject/wlan-cloud-ucentralsec/tree/main#changing-default-password). Please use these docs to find the actions that must be done **after** the deployment in order to start using your deployment.
### Ports
Every OpenWifi service is exposed via a separate port either directly on the host or through Traefik. For an overview of the exposed ports have a look into the deployment specific Docker Compose file. If you use your own certificates or make use of the [Letsencrypt LB deployment](#lb-deployment-with-letsencrypt-certificates), you can also configure different hostnames for the microservices.  
Please note that the OWProv-UI is exposed on port `8080(HTTP)/8443(HTTPS)` by default except for the Letsencrypt LB deployment, where the service listens on the default `80/443` HTTP(S) ports.
### owsec templates and wwwassets
On the startup of owsec directories for wwwassets and mailer templates are created from the base files included in Docker image. After the initial startup you may edit those files as you wish in the [owsec-data/persist](./owsec-data/persist) directory.
## Non-LB deployment with self-signed certificates
1. Switch into the project directory with `cd docker-compose/`.
2. Add an entry for `openwifi.wlan.local` in your hosts file which points to `127.0.0.1` or whatever the IP of the host running the deployment is.
3. Spin up the deployment with `docker-compose up -d`.
4. Check if the containers are up and running with `docker-compose ps`.
5. Add SSL certificate exceptions in your browser by visiting https://openwifi.wlan.local:16001, https://openwifi.wlan.local:16002, https://openwifi.wlan.local:16004 and https://openwifi.wlan.local:16005.
6. Connect to your AP via SSH and add a static hosts entry in `/etc/hosts` for `openwifi.wlan.local`. This should point to the address of the host the Compose deployment runs on.
7. Login to the UI `https://openwifi.wlan.local` and follow the instructions to change your default password.
8. To use the curl test scripts included in the microservice repositories set the following environment variables:
```
export OWSEC="openwifi.wlan.local:16001"
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
5. Login to the UI and and follow the instructions to change your default password.
## Non-LB deployment with PostgreSQL
1. Switch into the project directory with `cd docker-compose/`.
2. Set the following variables in the env files and make sure to uncomment the lines. It is highly recommended that you change the DB passwords to some random string.
### owgw.env
| Variable                           | Value/Description |
| ---------------------------------- | ----------------- |
| `STORAGE_TYPE`                     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_HOST`     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_USERNAME` | `owgw`            |
| `STORAGE_TYPE_POSTGRESQL_PASSWORD` | `owgw`            |
| `STORAGE_TYPE_POSTGRESQL_DATABASE` | `owgw`            |
### owsec.env
| Variable                           | Value/Description |
| ---------------------------------- | ----------------- |
| `STORAGE_TYPE`                     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_HOST`     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_USERNAME` | `owsec`           |
| `STORAGE_TYPE_POSTGRESQL_PASSWORD` | `owsec`           |
| `STORAGE_TYPE_POSTGRESQL_DATABASE` | `owsec`           |
### owfms.env
| Variable                           | Value/Description |
| ---------------------------------- | ----------------- |
| `STORAGE_TYPE`                     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_HOST`     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_USERNAME` | `owfms`           |
| `STORAGE_TYPE_POSTGRESQL_PASSWORD` | `owfms`           |
| `STORAGE_TYPE_POSTGRESQL_DATABASE` | `owfms`           |
### owprov.env
| Variable                           | Value/Description |
| ---------------------------------- | ----------------- |
| `STORAGE_TYPE`                     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_HOST`     | `postgresql`      |
| `STORAGE_TYPE_POSTGRESQL_USERNAME` | `owprov`          |
| `STORAGE_TYPE_POSTGRESQL_PASSWORD` | `owprov`          |
| `STORAGE_TYPE_POSTGRESQL_DATABASE` | `owprov`          |
### postgresql.env
| Variable             | Value      |
| -------------------- | ---------- |
| `POSTGRES_PASSWORD`  | `postgres` |
| `POSTGRES_USER`      | `postgres` |
| `OWGW_DB`            | `owgw`     |
| `OWGW_DB_USER`       | `owgw`     |
| `OWGW_DB_PASSWORD`   | `owgw`     |
| `OWSEC_DB`           | `owsec`    |
| `OWSEC_DB_USER`      | `owsec`    |
| `OWSEC_DB_PASSWORD`  | `owsec`    |
| `OWFMS_DB`           | `owfms`    |
| `OWFMS_DB_USER`      | `owfms`    |
| `OWFMS_DB_PASSWORD`  | `owfms`    |
| `OWPROV_DB`          | `owprov`   |
| `OWPROV_DB_USER`     | `owprov`   |
| `OWPROV_DB_PASSWORD` | `owprov`   |
3. Depending on whether you want to use [self-signed certificates](#non-lb-deployment-with-self-signed-certificates) or [provide your own](#non-lb-deployment-with-own-certificates), follow the instructions of the according deployment model. Spin up the deployment with `docker-compose -f docker-compose.yml -f docker-compose.postgresql.yml up -d`. It is recommended to create an alias for this deployment model with `alias docker-compose-postgresql="docker-compose -f docker-compose.yml -f docker-compose.postgresql.yml"`.
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
5. Login to the UI and follow the instructions to change your default password.
## OWLS deployment with self-signed certificates
To run a load simulation you need to obtain a TIP signed client certificate which will be used to connect to the gateway. The certificate CN has to start with the characters `53494d` like it is described [here](https://github.com/Telecominfraproject/wlan-cloud-owls#get-a-simulator-key). Be aware that since the OWLS deployment partly exposes the same ports on the host as the OpenWifi deployment, it is not intended that both run on the same host.
1. Copy or move your TIP signed load simulation client certificate into the `docker-compose/certs` directory. Don't forget to name the files `device-cert.pem` and `device-key.pem` or adapt the path names in the OWLS configuration if you're using different file names.
2. To be able to run load simulation tests against your OpenWifi deployment, you'll have to [configure the OWGW microservice](https://github.com/Telecominfraproject/wlan-cloud-owls#prepare-your-openwifi-gateway) to allow load simulation tests. You can do that by either editing the OWGW env file or doing the changes directly in the OWGW configuration file if it is exposed on the host.
3. Switch into the project directory with `cd docker-compose/owls`.
4. Add an entry for `openwifi-owls.wlan.local` in your hosts file which points to `127.0.0.1` or whatever the IP of the host running the OWLS deployment is.
5. Spin up the deployment with `docker-compose up -d`.
6. Check if the containers are up and running with `docker-compose ps`.
7. Add SSL certificate exceptions in your browser by visiting https://openwifi-owls.wlan.local:16001 and https://openwifi-owls.wlan.local:16007.
8. If you're using an OpenWifi deployment with self-signed certificates, you'll have to add a custom hosts entry for `openwifi.wlan.local` on the machine running the OWLS deployment pointing to the remote IP of your OpenWifi host.
9. Login to the UI by visiting https://openwifi-owls.wlan.local and follow the instructions to change your default password.
10. In the Simulation tab, click on the + sign on the right side to add a load simulation.
11. Fill out the required fields. MAC prefix is used for the MAC addresses of the simulated devices, so you can use any six-digit hexadecimal number. Specify the remote address of your OpenWifi gateway in the Gateway field, for example `https://openwifi.wlan.local:15002`. Adapt the rest of the settings according to your needs.
12. Click on the floppy disk icon to save your load simulation. You can run it by clicking the play symbol in the table view.

**Note**: All deployments create local volumes to persist mostly application, database and certificate data. In addition to that the `certs/` directory is bind mounted into the microservice containers. Be aware that for the bind mounts the host directories and files will be owned by the user in the container. Since the files are under version control, you may have to change the ownership to your user again before pulling changes.
