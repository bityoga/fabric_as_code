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

# Setting up MSP folder
filename=$(ls $FABRIC_CFG_PATH/msp/keystore | sort -n | head -1)
cp $FABRIC_CFG_PATH/msp/keystore/$filename $FABRIC_CFG_PATH/tls/server.key
filename=$(ls $FABRIC_CFG_PATH/msp/signcerts | sort -n | head -1)
cp $FABRIC_CFG_PATH/msp/signcerts/$filename $FABRIC_CFG_PATH/tls/server.crt

# Finish setting up the local MSP for the orderer
finishMSPSetup $FABRIC_CFG_PATH/msp
copyAdminCert $FABRIC_CFG_PATH/msp

# Create the path for storing the ledger
mkdir -p $FABRIC_CFG_PATH/ledger

# Starting the peer
peer node start #--peer-chaincodedev

