#FROM node:latest

# set the base image to Debian
# https://hub.docker.com/_/debian/
FROM debian:latest

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update the repository sources list
# and install dependencies
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get -y autoclean

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.9.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v

COPY ./server.js /home/node/register-server/
COPY ./package.json /home/node/register-server/
COPY config /home/node/register-server/config

WORKDIR /home/node/register-server
RUN mkdir -p /home/node/register-server/keys
RUN openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out ./keys/ca.key
RUN openssl req -new -x509 -days 3650 -key ./keys/ca.key -subj "/C=NO/ST=Rogaland/L=Stavanger/O=Global Security/OU=IT Department" -out ./keys/ca.crt

RUN openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out ./keys/server.key
RUN openssl req -new -key ./keys/server.key -subj "/C=NO/ST=Rogaland/L=Stavanger/O=Global Security/OU=IT Department/CN=localhost" -out ./keys/server.csr
RUN openssl x509 -days 3650 -req -in ./keys/server.csr -CAcreateserial -CA ./keys/ca.crt -CAkey ./keys/ca.key -out ./keys/server.crt
RUN rm -rfv node_modules/
RUN apt-get install -y python
RUN apt-get install -y build-essential
RUN npm install

