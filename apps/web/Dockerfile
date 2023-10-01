FROM node:20.5.1-slim

RUN apt-get update \
  && apt-get install -y iputils-ping net-tools dnsutils vim curl

WORKDIR /usr/src/app