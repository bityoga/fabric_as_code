
if (($IDX == 0)); then    
    CORE_PEER_MSPCONFIGPATH=/root/${AGENT_HOST}/msp
    # Create the application channel    
    CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel create -c appchannel -f /root/${AGENT_HOST}_cli/artifacts/appchannel.tx -o ${ORDERER_HOST}:7050 --outputBlock /root/${AGENT_HOST}_cli/artifacts/appchannel.block --tls --cafile $CORE_PEER_TLS_ROOTCERT_FILE

    #Update the channel with anchor peers
    CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel update -o ${ORDERER_HOST}:7050 -c appchannel -f /root/${AGENT_HOST}_cli/artifacts/appchannel_anchor.tx --tls --cafile $CORE_PEER_TLS_ROOTCERT_FILE 
fi
CORE_PEER_MSPCONFIGPATH=/root/${ADMIN_USER}/msp
# Join the peers to the application channel
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel join -b /root/${AGENT_HOST}_cli/artifacts/appchannel.block


# while true; do
#   sleep 0.1
# done