# MySoMe Network - Register Server (HTTPS Enabled)
## Allows registration of users to the MySoMeNetwork
- Test connection: *curl -k -X POST https://167.99.129.174:8080*
- Register a user: *curl -k -X POST -d "username=user1&password=password" https://167.99.129.174:8080/register*

## Start the server locally
### Via localhost. You have to generate the relevent keys/cert for running it in https mode
Execute the following from your project directory
- mkdir -p keys
- openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out ./keys/ca.key
- openssl req -new -x509 -days 3650 -key ./keys/ca.key -subj "/C=NO/ST=Rogaland/L=Stavanger/O=Global Security/OU=IT Department" -out ./keys/ca.crt
- openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out ./keys/server.key
- openssl req -new -key ./keys/server.key -subj "/C=NO/ST=Rogaland/L=Stavanger/O=Global Security/OU=IT Department/CN=localhost" -out ./keys/server.csr
- openssl x509 -days 3650 -req -in ./keys/server.csr -CAcreateserial -CA ./keys/ca.crt -CAkey ./keys/ca.key -out ./keys/server.crt
- npm install

### Via docker swarm
- docker-compose up
- Press "Ctrl-C" to stop
- docker rm register-server
- docker-compose push
- docker stack deploy MYSOMENET --compose-file docker-compose.yaml
#### Uninstall 
- docker service rm MYSOMENET_register-serve


#### Note
*CA Server* is currently pointed to MySoMeNetworkDev0 in DigitalOcean    
- In order to point the another Network
  - Change the value *"url": "[http/https]://hostname:port"* in *config/server.json*
  - You might also need to changes the revent values in *config/server.json* depending on the new CA server config


