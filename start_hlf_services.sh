#!/bin/bash
set -x #echo on

ansible-playbook -v 100.deploy_ca.yml --flush-cache -u root -i inventory/hosts_org1;
ansible-playbook -v 101.deploy_orderer.yml --flush-cache -u root -i inventory/hosts_org1;
ansible-playbook -v 102.deploy_peers.yml --flush-cache -u root -i inventory/hosts_org1;
ansible-playbook -v 103.deploy_cli.yml --flush-cache -u root -i inventory/hosts_org1;
#ansible-playbook -v 104.deploy_hlf_explorer.yml --flush-cache -u root;