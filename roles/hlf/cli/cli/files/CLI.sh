
#!/bin/bash
#set -x #echo on
if [ $INSTALL_BANK_CHAINCODE == "y" ]; then
    rm -rfv /root/CLI/chaincodes/articonf-bank-chaincode || true &&
    git clone https://github.com/bityoga/articonf-bank-chaincode.git /root/CLI/chaincodes/articonf-bank-chaincode || true &&
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/install.sh || true &&
    bash /root/CLI/chaincodes/articonf-bank-chaincode/bank_chaincode/shell_scripts_v2/instantiate.sh || true &&
    while true; do sleep 2; done;
else
    while true; do sleep 2; done;
fi
