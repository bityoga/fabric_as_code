#!/bin/bash
set -x #echo on

ansible-playbook -v 011.initialize_hosts.yml -u root &&
ansible-playbook -v 012.prepare_docker_images.yml -u root &&
ansible-playbook -v 013.mount_fs.yml -u root &&
ansible-playbook -v 014.spawn_swarm.yml -u root &&
ansible-playbook -v 015.deploy_swarm_visualizer.yml --flush-cache -u root &&
ansible-playbook -v 016.deploy_portainer.yml --flush-cache -u root &&
ansible-playbook -v 100.deploy_ca.yml --flush-cache -u root &&
ansible-playbook -v 101.deploy_orderer.yml --flush-cache -u root &&
ansible-playbook -v 102.deploy_peers.yml --flush-cache -u root &&
ansible-playbook -v 103.deploy_cli.yml --flush-cache -u root &&
ansible-playbook -v 104.deploy_hlf_explorer.yml --flush-cache -u root &&
#ansible-playbook -v 105.deploy_bank_app.yml --flush-cache -u root &&
ansible-playbook -v 106.deploy_rest_api.yml --flush-cache -u root