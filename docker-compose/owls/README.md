# OpenWifi OWLS Docker Compose
## Deployment with self-signed certificates
To run a load simulation you need to generate a specific Digicert-signed AP certificate which will be used to connect to the gateway. The certificate serial number has to start with the digits `53494d` since otherwise the gateway won't allow a load simulation. The rest of the serial number and the specified redirector URL can be chosen randomly. You only need to generate one AP certificate for your simulations.  
Be aware that since the OWLS deployment partly exposes the same ports on the host as the OpenWifi deployment, it is not intended that both run on the same host.
1. Copy or move your AP load simulation certificate into the `docker-compose/certs` directory. Don't forget to name the files `device-cert.pem` and `device-key.pem` or adapt the path names in the OWLS configuration if you're using different file names.
2. To be able to run load simulation tests against your OpenWifi SDK deployment, you'll have to [add the serial number of your generated AP certificate to the gateway configuration](https://github.com/Telecominfraproject/wlan-cloud-owls#prepare-your-openwifi-gateway). You can do that by either editing [owgw.env](../owgw.env) or doing the changes directly in your OWGW configuration file if it is exposed on your Docker host.
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
