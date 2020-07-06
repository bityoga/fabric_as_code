export FABRIC_CA_CLIENT_TLS_CERTFILES=$HOST_HOME/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$HOST_HOME/caadmin

echo "Enroll CA admin for $FABRIC_CA_NAME"
fabric-ca-client enroll -d -u https://ca-admin-$FABRIC_CA_NAME:$FABRIC_CA_SECRET@$FABRIC_CA_NAME:$FABRIC_CA_PORT