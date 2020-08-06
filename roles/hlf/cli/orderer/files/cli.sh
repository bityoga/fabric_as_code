mkdir -p ${HOST_HOME}/artifacts
configtxgen -configPath ${HOST_HOME} -channelID syschannel -profile SampleDevModeEtcdRaft -outputBlock ${HOST_HOME}/artifacts/genesis.block;
configtxgen -configPath ${HOST_HOME} -channelID appchannel -profile SampleSingleMSPChannel -outputCreateChannelTx ${HOST_HOME}/artifacts/appchannel.tx
configtxgen -configPath ${HOST_HOME} -channelID appchannel -profile SampleSingleMSPChannel -outputAnchorPeersUpdate ${HOST_HOME}/artifacts/appchannel_anchor.tx -asOrg ${ORG}MSP

while true; do
  sleep 0.1
done