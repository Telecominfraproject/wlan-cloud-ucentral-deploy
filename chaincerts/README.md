# Purpose

These utilities update the clientCAS configuration to set the supported chain certificates. It would be used in case of reissued or expired chain certificates.

# Usage

## Kubernetes

The *mkclientcas* utility generates the clientcas.pem section of the 
*values.openwifi-qa.yaml* and *values.openwifi-qa-insta.yaml* files inside
*../chart/environment-values/*.

To create the *clientcas.pem* section for *values.openwifi-qa.yaml*:
```
./mkclientcas -d -o clientcas.digicert
```

To create the *clientcas.pem* section for *values.openwifi-qa-insta.yaml*:
```
./mkclientcas -o clientcas.insta
```

Then edit the *values.openwifi-qa.yaml* and/or *values.openwifi-qa-insta.yaml* files accordingly to replace the *owgw.certs.clientcas.pem* section with the content from the respective clientcas.\* file.

## Docker Compose

The *mkclientcas* utility generates the *clientcas.pem* files for docker-compose using the -D flag.

To create the clientcas files:
```
./mkclientcas -D -d -o ../docker-compose/certs/clientcas_digicert.pem
./mkclientcas -D -o ../docker-compose/certs/clientcas.pem
```

## AP-NOS

The *mkclientcas* utility generates the *insta.pem* file using the -I flag.

To create the *insta.pem* file:
```
./mkclientcas -I -o insta.pem
```
