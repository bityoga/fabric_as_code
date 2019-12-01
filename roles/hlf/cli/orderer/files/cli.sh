configtxgen -configPath ${HOST_HOME}_cli -channelID syschannel -profile SysChannel -outputBlock ${HOST_HOME}_cli/genesis.block;
configtxgen -configPath ${HOST_HOME}_cli -channelID appchannel -profile AppChannel -outputCreateChannelTx ${HOST_HOME}_cli/appchannel.tx
configtxgen -configPath ${HOST_HOME}_cli -channelID appchannel -profile AppChannel -outputAnchorPeersUpdate ${HOST_HOME}_cli/appchannel_anchor.tx -asOrg ${ORG}

while true; do
  sleep 0.1
done