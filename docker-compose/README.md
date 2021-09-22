# Docker Compose
With the provided Docker Compose files you can instantiate a deployment of the uCentral microservices and related components. The repository contains a self-signed certificate and a TIP-signed gateway certificate which are valid for the `*.wlan.local` domain. You also have the possibility to generate and use Letsencrypt certs instead of the provided self-signed cert for everything except the uCentralGW websocket service.
## Deployment with self-signed certificates
1. Switch into the project directory with `cd docker-compose/`.
2. Add an entry for `ucentral.wlan.local` in your hosts file which points to `127.0.0.1` or whatever the IP of the host running the deployment is.
3. Since the deployment is split into multiple Compose and .env files it makes sense to create an alias, for example:
```
alias docker-compose-selfsigned="docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml --env-file .env.selfsigned"
```
Spin up the deployment with `docker-compose-selfsigned up -d` and make sure to always use the alias when executing `docker-compose` commands. You also have the possibility to scale specific services to a specified number of instances with `docker-compose-selfsigned up -d --scale SERVICE=NUM`, where `SERVICE` is the service name as defined in the Compose file.

4. Check if the containers are up and running with `docker-compose-selfsigned ps`.
5. Add the self-signed certificates to the system trust store of the containers with `./add-ca-cert.sh`.
6. Add SSL certificate exceptions in your browser by visiting https://ucentral.wlan.local:16001, https://ucentral.wlan.local:16002 and https://ucentral.wlan.local:16004.
7. Connect to your AP via SSH and add a static hosts entry in `/etc/hosts` for `ucentral.wlan.local` which points to the address of the host the Compose deployment runs on.
8. While staying in the SSH session, copy the content of `certs/restapi-ca.pem` on your local machine to your clipboard and append it to the file `/etc/ssl/cert.pem` on the AP. This way your AP will also trust the provided self-signed certificate.
9. Navigate to the UI `https://ucentral.wlan.local` and login with your uCentralSec authentication data.
10. To use the curl test scripts included in the microservice repositories set the following environment variables:
```
export UCENTRALSEC="ucentral.wlan.local:16001"
export FLAGS="-s --cacert <your-wlan-cloud-ucentral-deploy-location>/docker-compose/certs/restapi-ca.pem"
```

## Deployment with Letsencrypt certificates
1. Switch into the project directory with `cd docker-compose/`.
2. Adapt the following hostname and URI variables according to your environment.
### .env.letsencrypt
| Variable                        | Description                                                       |
| ------------------------------- | ----------------------------------------------------------------- |
| `UCENTRALGW_HOSTNAME`           | This will be used as a hostname for uCentralGW REST API           |
| `UCENTRALGWUI_HOSTNAME`         | This will be used as a hostname for uCentralGW-UI                 |
| `UCENTRALGWFILEUPLOAD_HOSTNAME` | This will be used as a hostname for uCentralGW fileupload         |
| `UCENTRALSEC_HOSTNAME`          | This will be used as a hostname for uCentralSec REST API          |
| `UCENTRALFMS_HOSTNAME`          | This will be used as a hostname for uCentralFms REST API          |
| `RTTYS_HOSTNAME`                | This will be used as a hostname for RTTYS                         |
| `SYSTEM_URI_UI`                 | Set this to your uCentralGW-UI URL                                |

### ucentralgw.env
| Variable                 | Description                                     |
| -----------------------  | ----------------------------------------------- |
| `FILEUPLOADER_HOST_NAME` | Set this to your uCentralGW fileupload hostname |
| `SYSTEM_URI_PUBLIC`      | Set this to your uCentralGW REST API public URL |
| `RTTY_SERVER`            | Set this to your public RTTY server hostname    |

### ucentralgw-ui.env
| Variable                  | Description                             |
| ------------------------- | --------------------------------------- |
| `DEFAULT_UCENTRALSEC_URL` | Set this to your public uCentralSec URL |

### ucentralsec.env
| Variable             | Description                              |
| -------------------- | ---------------------------------------- |
| `SYSTEM_URI_PUBLIC`  | Set this to your uCentralSec public URL  |

### ucentralsec.env
| Variable             | Description                              |
| -------------------- | ---------------------------------------- |
| `SYSTEM_URI_PUBLIC`  | Set this to your uCentralFms public URL  |

### traefik.env
| Variable                                            | Description                               |
| --------------------------------------------------- | ----------------------------------------- |
| `TRAEFIK_CERTIFICATESRESOLVERS_UCENTRAL_ACME_EMAIL` | Email address used for ACME registration. |

3. Since the deployment is split into multiple Compose and .env files it makes sense to create an alias, for example:
```
alias docker-compose-letsencrypt="docker-compose -f docker-compose.yml -f docker-compose.letsencrypt.yml --env-file .env.letsencrypt"
```
Spin up the deployment with `docker-compose-letsencrypt up -d` and make sure to always use the alias when executing `docker-compose` commands. You also have the possibility to scale specific services to a specified number of instances with `docker-compose-letsencrypt up -d --scale SERVICE=NUM`, where `SERVICE` is the service name as defined in the Compose file.

4. Check if the containers are up and running with `docker-compose-letsencrypt ps`.
5. Navigate to the UI and login with your uCentralSec authentication data.

**Note**: Both deployments create local volumes to persist mostly application, database and certificate data. In addition to that the `certs/` directory is bind mounted into the microservice containers. Be aware that for the bind mounts the host directories and files will be owned by the user in the container. Since the files are under version control, you may have to change the ownership to your user again before pulling changes.
