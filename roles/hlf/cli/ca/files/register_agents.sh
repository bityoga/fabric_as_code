export FABRIC_CA_CLIENT_TLS_CERTFILES=$HOST_HOME/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$HOST_HOME/caadmin

echo "Register agent with $FABRIC_CA_NAME"
fabric-ca-client register -d --id.name $AGENT_HOST --id.secret $AGENT_SECRET --id.type peer -u https://$FABRIC_CA_NAME:$FABRIC_CA_PORT