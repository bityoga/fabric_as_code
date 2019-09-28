# Helper functions to setup the MSP for the orderer service
function finishMSPSetup {
   if [ $# -ne 1 ]; then
      fatal "Usage: finishMSPSetup <targetMSPDIR>"
   fi
   if [ ! -d $1/tlscacerts ]; then
      mkdir -p $1/tlscacerts
      cp $1/cacerts/* $1/tlscacerts
      if [ -d $1/intermediatecerts ]; then
         mkdir -p $1/tlsintermediatecerts
         cp $1/intermediatecerts/* $1/tlsintermediatecerts
      fi
   fi
}

# Copy the org's admin cert into some target MSP directory
# This is only required if ADMINCERTS is enabled.
function copyAdminCert {
   if [ $# -ne 1 ]; then
      fatal "Usage: copyAdminCert <targetMSPDIR>"
   fi
   dstDir=$1/admincerts
   mkdir -p $dstDir   
   ORG_ADMIN_CERT=$1/signcerts/cert.pem   
   cp $ORG_ADMIN_CERT $dstDir
}


# Setting up GENESIS system block
# Download the required binaries to generate genesis blockchain
cd $FABRIC_CFG_PATH
$FABRIC_CFG_PATH/bootstrap.sh 1.4.3 -s -d
tar -zxvf $FABRIC_CFG_PATH/hyperledger-fabric-linux-amd64-1.4.3.tar.gz.1
rm $FABRIC_CFG_PATH/hyperledger-fabric-linux-amd64-1.4.3.tar.gz.1


# Setting up MSP folder
filename=$(ls $FABRIC_CFG_PATH/msp/keystore | sort -n | head -1)
cp $FABRIC_CFG_PATH/msp/keystore/$filename $FABRIC_CFG_PATH/tls/server.key
filename=$(ls $FABRIC_CFG_PATH/msp/signcerts | sort -n | head -1)
cp $FABRIC_CFG_PATH/msp/signcerts/$filename $FABRIC_CFG_PATH/tls/server.crt

# Finish setting up the local MSP for the orderer
finishMSPSetup $FABRIC_CFG_PATH/msp
copyAdminCert $FABRIC_CFG_PATH/msp

mkdir -p $FABRIC_CFG_PATH/ledger
$FABRIC_CFG_PATH/bin/configtxgen -outputBlock $FABRIC_CFG_PATH/ledger/genesis -profile modeEtcdRaft -channelID orderer-system-channel

# Cleanup process
rm -rf $FABRIC_CFG_PATH/config $FABRIC_CFG_PATH/bin 

# Start the ordering service 
orderer