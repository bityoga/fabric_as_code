idx=$1
type=$2

# These are static values, for each CA types
tlsca="tls"
orgca="org"

export FABRIC_CA_CLIENT_TLS_CERTFILES=$HOST_HOME/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$HOST_HOME/caadmin

if [$idx == 0]; then
  
  echo "Enroll CA admin for $FABRIC_CA_NAME"
  fabric-ca-client enroll -d -u https://ca-admin-$FABRIC_CA_NAME:$FABRIC_CA_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT
  
  echo "Regsiter orderer at $FABRIC_CA_NAME"
  fabric-ca-client register -d --id.name $PEER1_HOST --id.secret $PEER1_SECRET --id.type peer -u https://$FABRIC_CA_NAME:$FABRIC_CA_PORT
  
  echo "Regsiter peers at $FABRIC_CA_NAME"
  fabric-ca-client register -d --id.name $PEER2_HOST --id.secret $PEER2_SECRET --id.type peer -u https://$FABRIC_CA_NAME:$FABRIC_CA_PORT
  fabric-ca-client register -d --id.name $ORDERER_HOST --id.secret $ORDERER_SECRET --id.type orderer -u https://$FABRIC_CA_NAME:$FABRIC_CA_PORT

elif [ $idx != 0 && $type == $tlsca ]; then     
  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  # Enroll Agent
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/peer1
  fabric-ca-client enroll -d -u https://$PEER1_HOST:$PEER1_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT --enrollment.profile tls --csr.hosts $PEER1_HOST,127.0.0.1
  filename=$(ls $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_MSPDIR/keystore | sort -n | head -1)
  mv $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_MSPDIR/keystore/$filename $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
  
elif [ $idx != 0 && $type == $orgca ]; then
  echo "Regsiter admin at $FABRIC_CA_NAME"
  fabric-ca-client register -d --id.name admin-$FABRIC_CA_NAME --id.secret $FABRIC_CA_SECRET --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://$FABRIC_CA_NAME:$FABRIC_CA_PORT
    
  export FABRIC_CA_CLIENT_MSPDIR=msp
  # Enroll Agent 
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/peer1
  fabric-ca-client enroll -d -u https://$PEER1_HOST:$PEER1_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT
  
  #Enroll Admin
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/admin  
  fabric-ca-client enroll -d -u https://admin-$FABRIC_CA_NAME:$FABRIC_CA_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT

  # Transfer admincerts
  mkdir $HOST_HOME/$PEER1_HOST/msp/admincerts
  mkdir $HOST_HOME/$PEER2_HOST/msp/admincerts
  mkdir $HOST_HOME/$ORDERER_HOST/msp/admincerts
  cp $HOST_HOME/admin/msp/signcerts/cert.pem $HOST_HOME/$PEER1_HOST/msp/admincerts/admin-cert.pem
  cp $HOST_HOME/admin/msp/signcerts/cert.pem $HOST_HOME/$PEER2_HOST/msp/admincerts/admin-cert.pem
  cp $HOST_HOME/admin/msp/signcerts/cert.pem $HOST_HOME/$ORDERER_HOST/msp/admincerts/admin-cert.pem

else
  echo "type not supplied!"
fi

while true; do
  sleep 0.1
done