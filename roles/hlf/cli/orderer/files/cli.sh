mkdir -p ${HOST_HOME}/artifacts
configtxgen -configPath ${HOST_HOME} -channelID syschannel -profile SysChannel -outputBlock ${HOST_HOME}/artifacts/genesis.block;
configtxgen -configPath ${HOST_HOME} -channelID appchannel -profile AppChannel -outputCreateChannelTx ${HOST_HOME}/artifacts/appchannel.tx
configtxgen -configPath ${HOST_HOME} -channelID appchannel -profile AppChannel -outputAnchorPeersUpdate ${HOST_HOME}/artifacts/appchannel_anchor.tx -asOrg ${ORG}