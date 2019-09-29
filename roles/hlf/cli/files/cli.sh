# Create the application channel
FABRIC_CFG_PATH=/home/$ORDERER_HOST
configtxgen -profile InitApplicationChannel -outputCreateChannelTx /tmp/mysomechannel.tx -channelID mysomechannel

# Join the commiter peer to the channel
CORE_PEER_ADDRESS=$CPEER_HOST:7054
CORE_PEER_LOCALMSPID=bityogaCORE_PEER_LOCALMSPID=bityoga
CORE_PEER_MSPCONFIGPATH=/home/$CPEER_HOST/msp
CORE_PEER_TLS_ENABLED=false

FABRIC_CFG_PATH=/home/$CPEER_HOST
peer channel create -o $ORDERER_HOST:7050 -c mysomechannel -f /tmp/mysomechannel.tx --outputBlock /tmp/mysomechannel.block
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS peer channel join -b /tmp/mysomechannel.block



while true; do
  sleep 0.1
done

