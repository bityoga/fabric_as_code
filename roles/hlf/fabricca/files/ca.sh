type=$1
aica_affiliation=$2
uica_affiliation=$3

if [ $type == "rca" ]
then
    # Start the RCA
    nohup fabric-ca-server start -b $FABRIC_CA_USER:$FABRIC_CA_PASSWORD &

    # We wait until the root ca is started
    while ! nc -z localhost 7054; do   
    sleep 0.1 # wait for 1/10 of the second before check again
    done
    echo "$FABRIC_CA_USER launched"

    # Enroll with the rca user
    fabric-ca-client enroll -u https://$FABRIC_CA_USER:$FABRIC_CA_PASSWORD@$FABRIC_CA_USER:7054 --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem

    # Register the ICAs
    fabric-ca-client register --id.name $FABRIC_AICA_USER --id.type 'client' --id.affiliation $aica_affiliation --id.maxenrollments -1 --id.attrs '"hf.Registrar.Roles=peer",hf.Revoker=true,hf.IntermediateCA=true' --id.secret $FABRIC_AICA_PASSWORD --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem
    fabric-ca-client register --id.name $FABRIC_UICA_USER --id.type 'client' --id.affiliation $uica_affiliation --id.maxenrollments -1 --id.attrs '"hf.Registrar.Roles=user",hf.Revoker=true,hf.IntermediateCA=true' --id.secret $FABRIC_UICA_PASSWORD --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem
 
elif [ $type == "aica" ]
then
    # Start the AICA
    nohup fabric-ca-server start -u https://$FABRIC_CA_USER:$FABRIC_CA_PASSWORD@$FABRIC_CA_ROOT:7054 --intermediate.tls.certfiles $FABRIC_CA_HOME/tls-$FABRIC_CA_ROOT-cert.pem &
    
    # We wait until the ica ca is started
    while ! nc -z localhost 7054; do   
    sleep 0.1 # wait for 1/10 of the second before check again
    done
    echo "$FABRIC_CA_USER launched"

    fabric-ca-client enroll -u https://$FABRIC_CA_USER:$FABRIC_CA_PASSWORD@$FABRIC_CA_USER:7054 --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem

    # Register the ordering service    
    fabric-ca-client register -d --id.name $ORDERER_USER --id.type 'peer' --id.affiliation bityoga.hlf.agents.orderers --id.maxenrollments -1 --id.secret $ORDERER_PASSWORD --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem


    # Register peer services
    fabric-ca-client register -d --id.name $EPEER_USER --id.type 'peer' --id.affiliation bityoga.hlf.agents.peers --id.maxenrollments -1 --id.secret $EPEER_PASSWORD --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem
    fabric-ca-client register -d --id.name $CPEER_USER --id.type 'peer' --id.affiliation bityoga.hlf.agents.peers --id.maxenrollments -1 --id.secret $CPEER_PASSWORD --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem
    fabric-ca-client register -d --id.name $APEER_USER --id.type 'peer' --id.affiliation bityoga.hlf.agents.peers --id.maxenrollments -1 --id.secret $APEER_PASSWORD --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem    

    # Enroll the services, so as to generate the MSP
    # Orderer
    fabric-ca-client enroll -M $FABRIC_CA_HOME/client/$ORDERER_USER -u https://$ORDERER_USER:$ORDERER_PASSWORD@$FABRIC_CA_USER:7054 --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem
    #Peers
    fabric-ca-client enroll -M $FABRIC_CA_HOME/client/$EPEER_USER -u https://$EPEER_USER:$EPEER_PASSWORD@$FABRIC_CA_USER:7054 --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem
    fabric-ca-client enroll -M $FABRIC_CA_HOME/client/$CPEER_USER -u https://$CPEER_USER:$CPEER_PASSWORD@$FABRIC_CA_USER:7054 --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem
    fabric-ca-client enroll -M $FABRIC_CA_HOME/client/$APEER_USER -u https://$APEER_USER:$APEER_PASSWORD@$FABRIC_CA_USER:7054 --tls.certfiles $FABRIC_CA_HOME/tls-cert.pem

    # Provide group rx rights to msp/keystore folder, so that CLI can perform channel and chaincode operations
    chmod -R g+rx $FABRIC_CA_HOME/client/$EPEER_USER/keystore
    chmod -R g+rx $FABRIC_CA_HOME/client/$CPEER_USER/keystore
    chmod -R g+rx $FABRIC_CA_HOME/client/$APEER_USER/keystore

elif [ $type == "uica" ]
then
    # Remove the agent specific env variable values
    ORDERER_USER=""
    ORDERER_PASSWORD=""
    EPEER_USER=""
    EPEER_PASSWORD=""
    CPEER_USER=""
    CPEER_PASSWORD=""
    APEER_USER=""
    APEER_PASSWORD=""    

    # Start the UICA
    nohup fabric-ca-server start -u https://$FABRIC_CA_USER:$FABRIC_CA_PASSWORD@$FABRIC_CA_ROOT:7054 --intermediate.tls.certfiles $FABRIC_CA_HOME/tls-$FABRIC_CA_ROOT-cert.pem &    

    # We wait until the ica ca is started
    while ! nc -z localhost 7054; do   
    sleep 0.1 # wait for 1/10 of the second before check again
    done
    echo "$FABRIC_CA_USER launched"
else
    echo "CA TYPE not supplied"
    exit
fi

while true; do
  sleep 0.1
done