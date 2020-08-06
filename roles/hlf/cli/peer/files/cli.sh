CORE_PEER_TLS_ROOTCERT_FILE=/root/${AGENT_HOST}/tls-msp/tlscacerts/tls-${TLSCA_HOST}-7054.pem
CORE_PEER_MSPCONFIGPATH=/root/${ADMIN_USER}/msp 

if (($IDX == 0)); then    
    
    # Create the application channel    
    CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel create -c appchannel -f /root/${AGENT_HOST}_cli/artifacts/appchannel.tx -o ${ORDERER_HOST}:7050 --outputBlock /root/${AGENT_HOST}_cli/artifacts/appchannel.block --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}

    #Update the channel with anchor peers
    CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel update -o ${ORDERER_HOST}:7050 -c appchannel -f /root/${AGENT_HOST}_cli/artifacts/appchannel_anchor.tx --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}
fi

# Join the peers to the application channel
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=${AGENT_HOST}:7051 CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b /root/${AGENT_HOST}_cli/artifacts/appchannel.block


while true; do
  sleep 0.1
done