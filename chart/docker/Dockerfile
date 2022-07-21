FROM alpine:latest AS base

RUN apk add curl git jq bash

WORKDIR /cli

# OWGW
ARG OWGW_VERSION=master
RUN git clone https://github.com/Telecominfraproject/wlan-cloud-ucentralgw.git owgw \
  && cd owgw \
  && git checkout $OWGW_VERSION \
  && cd /cli \
  && cp owgw/test_scripts/curl/cli owgw_cli \
  && rm -rf owgw

# OWSEC
ARG OWSEC_VERSION=main
RUN git clone https://github.com/Telecominfraproject/wlan-cloud-ucentralsec.git owsec \
  && cd owsec \
  && git checkout $OWSEC_VERSION \
  && cd /cli \
  && cp owsec/test_scripts/curl/cli owsec_cli \
  && rm -rf owsec

# OWFMS
ARG OWFMS_VERSION=main
RUN git clone https://github.com/Telecominfraproject/wlan-cloud-ucentralfms.git owfms \
  && cd owfms \
  && git checkout $OWFMS_VERSION \
  && cd /cli \
  && cp owfms/test_scripts/curl/cli owfms_cli \
  && rm -rf owfms

# OWPROV
ARG OWPROV_VERSION=main
RUN git clone https://github.com/Telecominfraproject/wlan-cloud-owprov.git owprov \
  && cd owprov \
  && git checkout $OWPROV_VERSION \
  && cd /cli \
  && cp owprov/test_scripts/curl/cli owprov_cli \
  && rm -rf owprov

# OWAnalytics
ARG OWANALYTICS_VERSION=main
RUN git clone https://github.com/Telecominfraproject/wlan-cloud-analytics.git owanalytics \
  && cd owanalytics \
  && git checkout $OWANALYTICS_VERSION \
  && cd /cli \
  && cp owanalytics/test_scripts/curl/cli owanalytics_cli \
  && rm -rf owanalytics

# OWSub
ARG OWSUB_VERSION=main
RUN git clone https://github.com/Telecominfraproject/wlan-cloud-userportal.git owsub \
  && cd owsub \
  && git checkout $OWSUB_VERSION \
  && cd /cli \
  && cp owsub/test_scripts/curl/cli owsub_cli \
  && rm -rf owsub

COPY clustersysteminfo clustersysteminfo
COPY change_credentials change_credentials

ENTRYPOINT ["/cli/clustersysteminfo"]
