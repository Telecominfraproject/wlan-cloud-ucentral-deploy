# Docker Compose
With the provided Docker Compose files you can instantiate a deployment of the uCentral microservices and related components. The repository contains a self-signed certificate and a TIP-signed gateway certificate which are valid for the `*.wlan.local` domain. You also have the possibility to generate and use Letsencrypt certs  for the REST API and other components instead of the provided self-signed cert.
## Deployment with self-signed certificates
1. Switch into the project directory with `cd docker-compose/`.
2. Add an entry for `ucentral.wlan.local` in your hosts file which points to `127.0.0.1` or whatever the IP of the host running the deployment is. Be aware that by default only port `15002` (websocket) and `16003` (fileupload) are exposed on all interfaces and the rest only on localhost. Make sure to adapt that according to your needs.
3. Since the deployment is split into multiple Compose and .env files it makes sense to create an alias, for example:
```
alias docker-compose-selfsigned="docker-compose -f docker-compose.yml -f docker-compose.selfsigned.yml --env-file .env.selfsigned"
```
Spin up the deployment with `docker-compose-selfsigned up -d` and make sure to always use the alias when executing `docker-compose` commands. You also have the possibility to scale specific services to a specified number of instances with `docker-compose up -d --scale SERVICE=NUM`, where `SERVICE` is the service name as defined in the Compose file.

4. Check if the containers are up and running with `docker-compose-selfsigned ps`.
5. Add the self-signed certificates to the system trust store of the containers with `./add-ca-cert.sh`.
6. Add SSL certificate exceptions in your browser by visiting https://ucentral.wlan.local:16001, https://ucentral.wlan.local:16002 and https://ucentral.wlan.local:16004 (in Firefox you have to visit all three and add the exceptions, in Chrome adding one exception is sufficient).
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
| Variable                | Description                                                                                          |
| ----------------------- | ---------------------------------------------------------------------------------------------------- |
| `UCENTRALGW_HOSTNAME`   | This will be passed to the acme.sh script to create the certificate for the uCentralGW microservice  |
| `UCENTRALGWUI_HOSTNAME` | This will be passed to the acme.sh script to create the certificate for the uCentralGW-UI service    |
| `UCENTRALSEC_HOSTNAME`  | This will be passed to the acme.sh script to create the certificate for the uCentralSec microservice |
| `UCENTRALFMS_HOSTNAME`  | This will be passed to the acme.sh script to create the certificate for the uCentralFms microservice |
| `RTTYS_HOSTNAME`        | This will be passed to the acme.sh script to create the certificate for the RTTY server              |
| `SYSTEM_URI_UI`         | Set this to your uCentralGW-UI URL                                                                   |

### ucentralgw.env
| Variable                 | Description                             |
| -----------------------  | --------------------------------------- |
| `FILEUPLOADER_HOST_NAME` | Set this to your uCentralGW hostname    |
| `SYSTEM_URI_PRIVATE`     | Set this to your uCentralGW private URL |
| `SYSTEM_URI_PUBLIC`      | Set this to your uCentralGW public URL  |
| `RTTY_SERVER`            | Set this to your RTTY server hostname   |

### ucentralgw-ui.env
| Variable                  | Description                             |
| ------------------------- | --------------------------------------- |
| `DEFAULT_UCENTRALSEC_URL` | Set this to your public uCentralSec URL |

### ucentralsec.env
| Variable             | Description                              |
| -------------------- | ---------------------------------------- |
| `SYSTEM_URI_PRIVATE` | Set this to your uCentralSec private URL |
| `SYSTEM_URI_PUBLIC`  | Set this to your uCentralSec public URL  |

### ucentralsec.env
| Variable             | Description                              |
| -------------------- | ---------------------------------------- |
| `SYSTEM_URI_PRIVATE` | Set this to your uCentralFms private URL |
| `SYSTEM_URI_PUBLIC`  | Set this to your uCentralFms public URL  |

**Note**: Use the same hostname when specifying private and public URIs for the microservices. Docker will automatically route inter-container traffic via the uCentral Docker network since the hostnames resolve to IP addresses from this network inside the containers.

3. Since the deployment is split into multiple Compose and .env files it makes sense to create an alias, for example:
```
alias docker-compose-letsencrypt="docker-compose -f docker-compose.yml -f docker-compose.letsencrypt.yml --env-file .env.letsencrypt"
```
Spin up the deployment with `docker-compose-letsencrypt up -d` and make sure to always use the alias when executing `docker-compose` commands. You also have the possibility to scale specific services to a specified number of instances with `docker-compose up -d --scale SERVICE=NUM`, where `SERVICE` is the service name as defined in the Compose file.

4. Wait for the acme.sh container to issue all certificates. You can track the status in the logs with `docker-compose-letsencrypt logs -f acme.sh`. Check if everything runs smooth and wait for the line `Switching into daemon mode.` to appear.
5. Stop and remove the containers with `docker-compose-letsencrypt down` and uncomment the line in the `volumes` section of the `ucentralgw-ui` service in `docker-compose.letsencrypt.yml`. This step is necessary since the certificate for uCentralGW-UI has to be issued first and nginx won't start if the specified cert and key don't exist.
6. Deploy the containers again with `docker-compose-letsencrypt up -d`.
7. Check if the containers are up and running with `docker-compose-letsencrypt ps`.

**Note**: Both deployments create local volumes to persist mostly application, database and certificate data. In addition to that the `certs/` directory is bind mounted into the microservice containers. Be aware that for the bind mounts the host directories and files will be owned by the user in the container. Since the files are under version control, you may have to change the ownership to your user again before pulling changes.
