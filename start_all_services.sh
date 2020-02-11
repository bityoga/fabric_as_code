#!/bin/bash
set -x #echo on

ansible-playbook -v 011.initialize_hosts.yml -u root &&
ansible-playbook -v 012.prepare_docker_images.yml -u root &&
ansible-playbook -v 013.mount_fs.yml -u root &&
ansible-playbook -v 014.spawn_swarm.yml -u root &&
ansible-playbook -v 015.deploy_swarm_visualizer.yml --flush-cache -u root &&
ansible-playbook -v 100.deploy_ca.yml --flush-cache -u root && sleep 15 &&
ansible-playbook -v 101.deploy_orderer.yml --flush-cache -u root && sleep 10 &&
ansible-playbook -v 102.deploy_peers.yml --flush-cache -u root && sleep 10 &&
ansible-playbook -v 103.deploy_cli.yml --flush-cache -u root && sleep 10 &&
ansible-playbook -v 104.deploy_hlf_explorer.yml --flush-cache -u root