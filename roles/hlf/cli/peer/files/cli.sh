set -e
EXIT_CODE=0
if (($IDX == 0)); then    
    CORE_PEER_MSPCONFIGPATH=/root/${AGENT_HOST}/msp
    # Create the application channel    
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel create -c appchannel -f /root/${AGENT_HOST}_cli/artifacts/appchannel.tx -o ${ORDERER_HOST}:7050 --outputBlock /root/${AGENT_HOST}_cli/artifacts/appchannel.block --tls --cafile /root/${AGENT_HOST}/msp/tls/ca.crt --clientauth --certfile /root/${AGENT_HOST}/msp/tls/server.crt --keyfile /root/${AGENT_HOST}/msp/tls/server.key  || EXIT_CODE=$?

    #Update the channel with anchor peers    
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel update -o ${ORDERER_HOST}:7050 -c appchannel -f /root/${AGENT_HOST}_cli/artifacts/appchannel_anchor.tx --tls --cafile /root/${AGENT_HOST}/msp/tls/ca.crt --clientauth --certfile /root/${AGENT_HOST}/msp/tls/server.crt --keyfile /root/${AGENT_HOST}/msp/tls/server.key || EXIT_CODE=$?
else
    # We we have the IDX 1 running, we wait for 5 secs first
    sleep 5s;
fi
CORE_PEER_MSPCONFIGPATH=/root/${ADMIN_USER}/msp
CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
CORE_PEER_TLS_CLIENTCERT_FILE=/root/${AGENT_HOST}/msp/tls/server.crt #fully qualified path of the client certificate
CORE_PEER_TLS_CLIENTKEY_FILE=/root/${AGENT_HOST}/msp/tls/server.key #fully qualified path of the client private key
# Join the peers to the application channel
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_CLIENTAUTHREQUIRED=$CORE_PEER_TLS_CLIENTAUTHREQUIRED CORE_PEER_TLS_CLIENTCERT_FILE=$CORE_PEER_TLS_CLIENTCERT_FILE CORE_PEER_TLS_CLIENTKEY_FILE=$CORE_PEER_TLS_CLIENTKEY_FILE  peer channel join -b /root/${AGENT_HOST}_cli/artifacts/appchannel.block || EXIT_CODE=$?

echo $EXIT_CODE
# while true; do
#   sleep 0.1
# doneCORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_CLIENTAUTHREQUIRED=$CORE_PEER_TLS_CLIENTAUTHREQUIRED CORE_PEER_TLS_CLIENTCERT_FILE=$CORE_PEER_TLS_CLIENTCERT_FILE CORE_PEER_TLS_CLIENTKEY_FILE=$CORE_PEER_TLS_CLIENTKEY_FILE  peer channel join -b /root/${AGENT_HOST}_cli/artifacts/appchannel.block --ordererTLSHostnameOverride 165.232.76.37