# Fabric as Code
##### TLS
##### Docker Swarm
##### Ansible
##### Moduler
##### Easily Configurable Architecture
![Architecture Diagram](https://github.com/achak1987/fabric_as_code/blob/master/fabric_as_code.jpg)



....
#TODO - Work on documentation

### Install, Instanciate and Test Chaincode
  docker exec -it <<CLI_ID>> bash

CORE_PEER_ADDRESS=peer2:7051
CORE_PEER_MSPCONFIGPATH=/root/admin/msp
CORE_PEER_TLS_ROOTCERT_FILE=/root/${PEER2_HOST}/tls-msp/tlscacerts/tls-${TLSCA_HOST}-7054.pem
#### Install the chaincode on peer 2
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode install -n testcc -v 1.0 -l node -p /root/CLI/chaincodes/test_chaincode/node

#### Instanciate the chaincode
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode instantiate -C appchannel -n testcc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -o ${ORDERER_HOST}:7050 --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}

#### GET
CORE_PEER_ADDRESS=peer2:7051 CORE_PEER_MSPCONFIGPATH=/root/peer2/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode query -C appchannel -n testcc -c '{"Args":["query","a"]}'

#### PUT
CORE_PEER_ADDRESS=peer2:7051 CORE_PEER_MSPCONFIGPATH=/root/peer2/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode invoke -C appchannel -n testcc -c '{"Args":["invoke","a","b","10"]}' --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}

#### GET
CORE_PEER_ADDRESS=peer2:7051 CORE_PEER_MSPCONFIGPATH=/root/peer2/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode query -C appchannel -n testcc -c '{"Args":["query","a"]}'

## Next Version(s)
- couchdb as State DB
- Customizable Policies for Channels (Sys and App)
- Mutual TLS
- Raft as Orderer
- Add new Organization to consortium: system channel, application channel
- Create new Channel
- Update/Remove Organization from consortium: system channel, application channel
- Update/Remove Channel
