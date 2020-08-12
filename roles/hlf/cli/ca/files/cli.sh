#### Pretty Print #####
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 
# e.g.: printf "${GREEN} I love Stack Overflow$NC\n"
#######################
type=$1

# These are static values, for each CA types
tlsca="tls"
orgca="org"

export FABRIC_CA_CLIENT_TLS_CERTFILES=$HOST_HOME/ca-cert.pem

printf "${RED}IDX=$IDX${NC}\n"

if (($IDX == 0)); then
  printf "${GREEN}Enroll CA root for $FABRIC_CA_NAME${NC}\n"
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/caadmin  
  fabric-ca-client enroll -d -u https://ca-admin-$FABRIC_CA_NAME:$FABRIC_CA_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT
    
  printf "${GREEN}Register admin ($ADMIN_USER) at $FABRIC_CA_NAME${NC}\n"
  fabric-ca-client register -d --id.name $ADMIN_USER --id.secret $ADMIN_SECRET --id.type admin --id.attrs '"hf.Registrar.Roles=peer,orderer,client",hf.Revoker=true'  

  printf "${GREEN}Enroll admin ($ADMIN_USER) for $FABRIC_CA_NAME${NC}\n"
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/$ADMIN_USER  
  fabric-ca-client enroll -d -u https://$ADMIN_USER:$ADMIN_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT

    printf "${GREEN}Make $AGENT_HOST admin of itself${NC}\n"
    mkdir -p $HOST_HOME/$ADMIN_USER/msp/admincerts        
    cp $HOST_HOME/$ADMIN_USER/msp/signcerts/cert.pem $HOST_HOME/$ADMIN_USER/msp/admincerts/${ADMIN_USER}-cert.pem
fi

  # Delay the registration and enrollment of agents, by few seconds so that the registration and enrollment of admins are done first.
  sleep 5s

if [ $type == $tlsca ]; then      
  # We make sure that we are pointed to the admin user, prior to registering agents
  printf "${GREEN}Register agent $AGENT_HOST of type $AGENT_TYPE at $FABRIC_CA_NAME${NC}\n"
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/$ADMIN_USER  
  fabric-ca-client register -d --id.name $AGENT_HOST --id.secret $AGENT_SECRET --id.type $AGENT_TYPE -u https://$FABRIC_CA_NAME:$FABRIC_CA_PORT
    
  # Enroll Agent
  printf "${GREEN}Enroll agent $AGENT_HOST for $FABRIC_CA_NAME${NC}\n"
  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/$AGENT_HOST  
  fabric-ca-client enroll -d -u https://$AGENT_HOST:$AGENT_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT --enrollment.profile tls --csr.hosts ${AGENT_HOST}

  filename=$(ls $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_MSPDIR/keystore | sort -n | head -1)
  mv $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_MSPDIR/keystore/$filename $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
  
elif [ $type == $orgca ]; then
  # We make sure that we are pointed to the admin user, prior to registering agents
  printf "${GREEN}Register agent $AGENT_HOST of type $AGENT_TYPE at $FABRIC_CA_NAME${NC}\n"
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/$ADMIN_USER  
  fabric-ca-client register -d --id.name $AGENT_HOST --id.secret $AGENT_SECRET --id.type $AGENT_TYPE -u https://$FABRIC_CA_NAME:$FABRIC_CA_PORT 

  # Enroll Agent 
  printf "${GREEN}Enroll agent $AGENT_HOST for $FABRIC_CA_NAME${NC}\n"
  export FABRIC_CA_CLIENT_MSPDIR=msp
  export FABRIC_CA_CLIENT_HOME=$HOST_HOME/$AGENT_HOST  
  fabric-ca-client enroll -d -u https://$AGENT_HOST:$AGENT_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT

  # Transfer admincerts
  mkdir $HOST_HOME/$AGENT_HOST/msp/admincerts    
  # Make the admin user as admin for the agents
  cp $HOST_HOME/$ADMIN_USER/msp/signcerts/cert.pem $HOST_HOME/$AGENT_HOST/msp/admincerts/$ADMIN_USER-cert.pem   

else
  printf "${RED}type not supplied!${NC}\n"  
fi

# while true; do
#   sleep 0.1
# done