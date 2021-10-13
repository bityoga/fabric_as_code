
#!/bin/bash
#set -x #echo on
if [ $INSTALL_BANK_CHAINCODE == "y" ]; then
    rm -rfv /root/CLI/chaincodes/articonf-bank-chaincode || true &&
    git clone https://github.com/bityoga/articonf-bank-chaincode.git /root/CLI/chaincodes/articonf-bank-chaincode || true &&
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/install.sh || true &&
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/instantiate.sh || true &&
    #### TIC DASHBOARD NODE APP DEPLOYMENT STARTS HERE ####
    # 1) Install node js in ALpine Linux (CLI service runs Alpine Linux) (Reference : https://superuser.com/questions/1125969/how-to-install-npm-in-alpine-linux)
    apk add --update nodejs npm || true &&
    # 2) Remove previous tic_dashboard code if exists
    rm -rf /root/CLI/tic_dashboard  || true &&
    # 3) Git clone tic_dashboard code to "/root/CLI"
    git clone https://github.com/bityoga/tic_dashboard.git /root/CLI/tic_dashboard || true &&
    # 4) Run npm install under "/root/CLI/tic_dashboard"
    npm --prefix /root/CLI/tic_dashboard install /root/CLI/tic_dashboard  || true &&
    # 5) Start tic_dashboard app
    node /root/CLI/tic_dashboard/app.js  || true &
    #### TIC DASHBOARD NODE APP DEPLOYMENT ENDS HERE ####
    while true; do sleep 2; done;
else
    while true; do sleep 2; done;
fi
