
#!/bin/bash
set -x #echo on
if [ $INSTALL_BANK_CHAINCODE == "y" ]; then  
    git clone https://github.com/bityoga/articonf-bank-chaincode.git /root/CLI/chaincodes/articonf-bank-chaincode && 
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/install.sh && 
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/instantiate.sh && 
    while true; do sleep 2; done;
else
    while true; do sleep 2; done;
fi
