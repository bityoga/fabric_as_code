
#!/bin/bash
installTiCDashBoard()
{
#### TIC DASHBOARD NODE APP DEPLOYMENT STARTS HERE ####
# 1) apk add unzip
apk add unzip || true &&
# 2) Install node js in ALpine Linux (CLI service runs Alpine Linux) (Reference : https://superuser.com/questions/1125969/how-to-install-npm-in-alpine-linux)
apk add --update nodejs npm || true &&
# 3) Remove previous tic_dashboard code if exists
rm -rf /root/CLI/tic_dashboard  || true &&
# 4) Git clone tic_dashboard code to "/root/CLI"
git clone --single-branch --branch addRestApiInstructions https://github.com/bityoga/tic_dashboard.git /root/CLI/tic_dashboard || true &&
# 5) Replace template copied "/root/CLI/tic_dashboard/api_config.json" with tic_dashboard_config.json
cp /root/CLI/tic_dashboard_config.json /root/CLI/tic_dashboard/api_config.json || true &&
# 6) Run npm install under "/root/CLI/tic_dashboard"
npm --prefix /root/CLI/tic_dashboard install /root/CLI/tic_dashboard  || true &&
# 7) Start tic_dashboard app
cd /root/CLI/tic_dashboard && node app.js  || true &
#node /root/CLI/tic_dashboard/app.js  || true &
#### TIC DASHBOARD NODE APP DEPLOYMENT ENDS HERE ####
}
#set -x #echo on
if [ $INSTALL_BANK_CHAINCODE == "y" ]; then
    rm -rf /root/CLI/chaincodes/articonf-bank-chaincode || true &&
    git clone https://github.com/bityoga/articonf-bank-chaincode.git /root/CLI/chaincodes/articonf-bank-chaincode || true &&
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/install.sh || true &&
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/instantiate.sh || true &&
    installTiCDashBoard
    while true; do sleep 2; done;
else
    installTiCDashBoard
    while true; do sleep 2; done;
fi
