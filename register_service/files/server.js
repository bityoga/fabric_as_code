var path = require('path');
var util = require('util');
var os = require('os');
var https  = require('https');
var fs = require('fs');
var express = require('express');
var bodyParser = require('body-parser');
var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');
var fabric_client = new Fabric_Client();

// Configuration for this server
var server_config = require('./config/server.json');
// Configuration of the RCA/ICA (CA) server
var ca_config = require('./config/ca.json');

var fabric_ca_client = null;
var admin_user = null;

// Setting up https
var options = {
    key: fs.readFileSync('./keys/server.key'),
    cert: fs.readFileSync( './keys/server.crt'),
    ca: fs.readFileSync( './keys/server.csr')   
}

// Create a service (the app object is just a callback).
var app = express();
//support parsing of application/json type post data
app.use(bodyParser.json());
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({
	extended: true
}));

app.post('/', async function(req, res) {
    res.setHeader('Content-Type', 'text/html');
    res.end('here i am \n');

})

app.post('/register', async function(req, res) {
    // at this point we should have the admin user
    // first need to register the user with the CA server
    var status = true;
    try {
        await fabric_ca_client.register({enrollmentID: req.body.username, enrollmentSecret: req.body.password, role: server_config.userrole}, admin_user);
    } catch(err) {   
        status = false;                           
        console.error('Could not to register user. Error: ' + err.stack ? err.stack : err);
    }
    res.end('{"status": '+ '"'+ status + '"}');
})

async function enrollAdmin() {
    let return_value;
    try {
        // Create a new CA client for interacting with the CA.
        const caInfo = ccp.certificateAuthorities[CA_ORGANISATION_NAME];
        console.log(caInfo);
        const caTLSCACerts = [];
        //const caTLSCACerts = caInfo.tlsCACerts.pem;
        const ca = new FabricCAServices(caInfo.url, { trustedRoots: caTLSCACerts, verify: false }, caInfo.caName);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');

        const wallet = new FileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the admin user.
        const adminExists = await wallet.exists('admin');
        if (adminExists) {
            return_value = 'An identity for the admin user "admin" already exists in the wallet';
        }

        else {
            // Enroll the admin user, and import the new identity into the wallet.
            const enrollment = await ca.enroll({ enrollmentID: admin_username, enrollmentSecret: admin_password });
            const identity = X509WalletMixin.createIdentity(ORGANISATION_MSP, enrollment.certificate, enrollment.key.toBytes());
            await wallet.import('admin', identity);
            return_value = 'Successfully enrolled admin user "admin" and imported it into the wallet';
        }
    } 
    catch (error) {
        
        return_value = `Failed to enroll admin user "admin": ${error}`;
    }
    finally {
        console.log("'enrollAdmin' function -> returning value");
        return return_value;
    }
}

var server = https.createServer(options, app);

server.listen(server_config.port, function() {
    console.info('****************** SERVER STARTED ************************');
    console.info('***************  https://%s:%s  ******************', server_config.host, server_config.port);    
    // use the a location for the state store (where the users' certificate are kept)
    // and the crypto store (where the users' keys are kept). Only admin cred should be stored
    var	tlsOptions = {
        trustedRoots: [],
        verify: false
    };        
    fabric_ca_client = new Fabric_CA_Client(ca_config.bityogaca.url, tlsOptions , ca_config.bityogaca.caname);

    // need to enroll it with CA server
    return fabric_ca_client.enroll({
        enrollmentID: ca_config.bityogaca.enrollmentID,
        enrollmentSecret: ca_config.bityogaca.enrollmentSecret
        }).then((enrollment) => {
        console.log('Successfully enrolled admin user "admin"');
        return fabric_client.createUser(
            {username: ca_config.bityogaca.enrollmentID,
                mspid: ca_config.bityogaca.mspid,
                cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate },
                skipPersistence: true
            });
        }).then((user) => {
            admin_user = user;
            return fabric_client.setUserContext(admin_user, skipPersistence=true);            
        }).catch((err) => {
            console.error('Failed to enroll admin. Error: ' + err.stack ? err.stack : err);
            throw new Error('Failed to enroll admin');
        });   
});
