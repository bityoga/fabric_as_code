CORE_PEER_LOCALMSPID=bityoga
CORE_PEER_TLS_ENABLED=false

############## Create the application channel transaction ###########################
FABRIC_CFG_PATH=/home/$ORDERER_HOST
configtxgen -profile InitApplicationChannel -outputCreateChannelTx /home/cli/mysomechannel.tx -channelID mysomechannel # New Channel Tx

# AC: TODO need to implement policies for anchor peers
# configtxgen -profile InitApplicationChannel -outputAnchorPeersUpdate /home/cli/bityogaAnchor.tx -channelID mysomechannel -asOrg bityoga # Anchor Peer Tx

echo "Creating channel mysomechannel"
# Join the commiter peer to the channel
CORE_PEER_ADDRESS=$CPEER_HOST:7054
CORE_PEER_MSPCONFIGPATH=/home/$CPEER_HOST/msp

FABRIC_CFG_PATH=/home/$CPEER_HOST

peer channel create -o $ORDERER_HOST:7050 -c mysomechannel -f /home/cli/mysomechannel.tx --outputBlock /home/cli/mysomechannel.block
echo "Channel mysomechannel was successfully created!"

echo "Commiter peer joining channel mysomechannel..."
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS peer channel join -b /home/cli/mysomechannel.block
echo "Commiter peer joined channel mysomechannel successfully!"

############# Update the application channel transaction for adding the endorser peer ###################
CORE_PEER_ADDRESS=$EPEER_HOST:7054
CORE_PEER_MSPCONFIGPATH=/home/$EPEER_HOST/msp

FABRIC_CFG_PATH=/home/$EPEER_HOST

echo "Endorser peer joining channel mysomechannel..."
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS peer channel join -b /home/cli/mysomechannel.block
echo "Endorser peer joined channel mysomechannel successfully!"

############# Update the application channel transaction for adding the anchor peer ###################
CORE_PEER_ADDRESS=$APEER_HOST:7054
CORE_PEER_MSPCONFIGPATH=/home/$APEER_HOST/msp

FABRIC_CFG_PATH=/home/$APEER_HOST

echo "Anchor peer joining channel mysomechannel..."
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS peer channel join -b /home/cli/mysomechannel.block
echo "Anchor peer joined channel mysomechannel successfully!"

# # AC: TODO need to implement policies for anchor peers
# echo "Updating channel mysomechannel with anchor peer details"
# peer channel update -o $ORDERER_HOST:7050 -c mysomechannel -f /tmp/bityogaAnchor.tx --outputBlock /home/cli/mysomechannelbityogaAnchor.block
# echo "Channel mysomechannel was successfully updated with anchor peer!"


while true; do
  DATE=`date +%Y%m%d`
  HOUR=`date +%H`
  sleep 60
  echo "I am alive at $DATE $HOUR hour"
done

