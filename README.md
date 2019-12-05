# Fabric as Code
The current project enables provisioning of Hyperledger Fabric (HLF) [https://www.hyperledger.org/projects/fabric] cluster over a host of machines managed by Docker Swarm [https://docs.docker.com/engine/swarm/]. It offers an easily configurable mechanism for initializing and setting up the cluster.
Currently it support the spinning up of HLF cluster for just one organization, however, we are worrking towards mechanism for easily adding new organization to an exisiting cluster. Please see the Overview and TODO sections bellow

![Architecture Diagram](https://github.com/achak1987/fabric_as_code/blob/master/fabric_as_code.jpg)

## Overview
- Hyperledger Fabric v1.4.3
- Create a Docker Swarm Network
- Provision HLF over the Docker Swarm
- TLS enabled 
- Solo orderer
- CouchDB and LevelDB peer databases
- Single Org Setup
- Single Sys / App channel setup
## Todo
- Customizable Policies for Channels (Sys and App)
- Mutual TLS
- Raft as Orderer
- Add new Organization to consortium: system channel, application channel
- Add new Channel
- Update/Remove Organization from consortium: system channel, application channel
- Update/Remove Channel

## Pre-requisites: 
- Ensure that you have installed ansible version 2.9.x on your local machine. Please see [https://www.ansible.com/] for further details on installing ansible on your local machine.
Once ensible is installed, you can verify its version using the command `ansible --version` on you bash shell. you should receive an output such as this:
```
ansible 2.9.1
config file = /Users/antorweep/Documents/dev/mysome_glusterfs/ansible.cfg
configured module search path = ['/Users/antorweep/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
executable location = /usr/local/bin/ansible
python version = 3.7.4 (default, Jul  9 2019, 18:13:23) [Clang 10.0.1 (clang-1001.0.46.4)]
```
- Furthermore, on your local machine you need to have some ansible plugins installed.
  - Navigate to the folder `mysome_glusterfs`
  - Execute the command `ansible-galaxy install -r requirements.yml`

- The remote machines donot need ansible installed. However, all remote hosts **must** have python version `2.7.x` or `above`
- Gluster FS [https://www.gluster.org/] is used as persistent storage for all docker services hosted by an organization. 
  - In is required to have a seperate GlusterFS cluster in order to run this project.
  - We have created an easily deployable package for creating a GlusterFS cluster.
  Please check: [https://github.com/achak1987/mysome_glusterfs]

[![Installation Guide](https://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg)](https://youtu.be/b1DYPJG6_Xs)

## Configuration
There are very few parameters to be configured currently. All configurations are made inside *all.yml*. 
- If you are using the automated process for host setup (*see bellow*), it needs few steps to enable ansible to setup the remote environment
  - **API token** !Required
    - In order to connect with Digital Ocean. 
    - Please see [https://www.digitalocean.com/docs/api/create-personal-access-token/]
    - Once you get the token, please find `do_oauth_token` in `all.yml` and set its value there
  - **SSH Keys** !Required
    - In order for setting up the cluster, ansible needs ssh password less login to the host machines.
    - Your ssh public key from your local machines should be registered with digital ocean, see [https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/] 
    - Once you have the ssh keys registered with Digital Ocean, you need to retrived ths ssh key ids from digital ocean. You can execute the following command on the bash on your local machine to get  this ids: `curl -X GET -silent "https://api.digitalocean.com/v2/account/keys" -H "Authorization: Bearer API token`
    - This will get a list of all ssh keys stored to your Digital Ocean account. You need to find the **numeric id** associated with your ssh key name. 
    - Once you get the ssh key id, please find `ssh_keys` in `all.yml` and set its value there within the `[]` brackets
  - **GLusterFS Setup** !Required
    - `gluster_cluster_volume` specifies the name of the created glusterfs volume. 
    - `gluster_cluster_host0` the ip address of any one of the machines of your glusterfs cluster
  - **config vars** [Optional]
    - Under the section *Hyperledger Fabric Network config vars*, there are various values for your organization and credentials of the agents and services running within you HLF cluster for your organization. 
    - You may choose the change them
  - ** CAs ** [Optional]
    - This projects spins up two CAs
      - ORGCA: Generates the MSPs for the agents (peers, agents, clients, users, admins) to interact with the Blockchain Network
      - TLSCA: Generates the MSPs for the agents (peers, agents, clients, users, admins) to estabilsh TLS communication with themselves or with the outside world. 
    - You may choose the change the number of *replicas* hosted by Docker Swarm or the database used by the CA (default: SQLITE) to Postgres or MySQL. 
      - **Note: Postgres or MySQL is not supported as of now**
  - ** Orderer ** [Optional]
    - This projects spins up one Ordering service for each organization
    - Currently, only solo ordering is supported. 
    - However, the target is to support only RAFT based ordering. Therefore, the concept of hosting one ordering services per organization following a leader and follower model.
    - You may choose the change the number of *replicas* hosted by Docker Swarm
  - ** Peers **  [Optional]
    - Two peers are supported currently
    - Peer1: Is the Anchor and Comitter peer 
    - Peer2- Is the endorser peer
    - In future, mechanisms would be introduces for easily adding and configuring more number of peers
    - You may choose the change the number of *replicas* for each of to peers

## Defining the remote host machines
In order to set up hlf cluster we would need a set of host machines. Ansible will comunicate with these machines and setup your cluster.

There are two mechanisms to set up the remote machines. Either manually or automated. However, the automated process currently only works on Digital Ocean. It is recommended to move with the automated process as of now

### Automated
- Please navigate to the file `inventory/hosts_template`
- It looks as follows:
```
[all:children]
swarm_manager_prime
swarm_managers
swarm_workers

[swarm_manager_prime]


[swarm_managers]


[swarm_workers]


```
- In order the specify the host machines, you need to populate this file `inventory/hosts_template` with the names of the host that you want to create. Each line/row in the file would represent a host machine. The lines with square brackets  `[]` represents groups for internal reference in the project and **must not be changed**. Please fill each line under a group in the format: `hostname"`
  - `swarm_manager_prime`: represents the host machine that will act as swarm master
  - `swarm_managers`: represents the backup masters
  - `swarm_workers`: represents the workers
  - `hostname`: can be any name. Must be unique for each machine. The project will internally refer to the machines with this name
- The following *example* defines 5 machines as remote hosts, with hlf0 acting as master, hlf1 as backup master and hlf[2-4] as swarm workers
```
[all:children]
swarm_manager_prime
swarm_managers
swarm_workers

[swarm_manager_prime]
hlf0

[swarm_managers]
hlf0
hlf1

[swarm_workers]
hlf2
hlf3
hlf4
```

- Next we would run the following playbooks to create
    - the number of VMs / Droplets
    - a block mount on each machines
- Playbook: `000.init.yml`
    - Execute: `ansible-playbook -v 000.init.yml`
    - Create a host file  inside inventory that would be filled up with the ips of the created host machines
- Playbook: `001.spawn_droplets.yml`
  - Execute: `ansible-playbook -v 001.spawn_droplets.yml`
  - Creates the specified number of host machines on digital ocean. 

### Manual
- Please navigate to the file `inventory/hosts_template`
- It looks as follows:
```
[all:children]
swarm_manager_prime
swarm_managers
swarm_workers

[swarm_manager_prime]


[swarm_managers]


[swarm_workers]

```
- Rename this file as `inventory/hosts`
- In order the specify the host machines, you need to populate this file `inventory/hosts_template` with the names of the host that you want to create. Each line/row in the file would represent a host machine. The lines with square brackets  `[]` represents groups for internal reference in the project and **must not be changed**. Please fill each line under a group in the format: `hostname ansible_host=remote.machine1.ip.adress"`
  - `hostname`: can be any name. Must be unique for each machine. The project will internally refer to the machines with this name
  - `ansible_host`: the ip address of the remote host. This machine should be accessable over the network with this ip address
  - `ansible_python_interpreter`: In order for ansible to work, we need python 2.7.x or above available on each remote machine. Here we specify the **path of python on the remote machine** so that our local ansible project know where to find python on these machines.
- The following *example* defines 3 machines as remote hosts
```
[all:children]
swarm_manager_prime
swarm_managers
swarm_workers

[swarm_manager_prime]
hlf0 ansible_host=147.182.121.59

[swarm_managers]
hlf0 ansible_host=147.182.121.59
hlf1 ansible_host=117.247.73.159

[swarm_workers]
hlf2 ansible_host=157.245.79.195
hlf3 ansible_host=157.78.79.201
hlf4 ansible_host=157.190.65.188
```
- **!!!Required: Ensure that you have password less SSH for these host for the user root**

## Setting up HLF
Setting up of hyperledger fabric cluster requires the following steps. Creating the infrastructure with all dependencies installed and starting the hlf services in all the host machines. Finally, there is also mounting the glusterfs point.

- Playbook: `011.initialize_hosts.yml`
  - Execute: `ansible-playbook -v 011.initialize_hosts.yml -u root`
  - Sets up the remote host machines with the dependencies and pre-requisite libraries
- Playbook: `012.prepare_docker_images.yml`
  - Execute: `ansible-playbook -v 012.prepare_docker_images.yml -u root`
  - Downloads the required HLF images from docker hub
- Playbook: `013.mount_fs.yml`
    - Execute: `ansible-playbook -v 013.mount_fs.yml -u root`
    - Mounts the glusterfs cluster. into each host machine so that the docker services can mount this persistent filesystem into their containers
- Playbook: `014.spawn_swarm.yml`
    - Execute: `ansible-playbook -v 014.spawn_swarm.yml -u root`
    - Starts a docker swarm cluster as specified in `inventory/hosts`
- Playbook: `100.deploy_ca`
    - Execute: `ansible-playbook -v 100.deploy_ca -u root`
    - Deploys the organizational and tls CAs to docker swarm. Also creates the required initial users on both CAs for the network to be operational
- Playbook: `101.deploy_orderer`
    - Execute: `ansible-playbook -v 101.deploy_orderer -u root`
    - Deploys the Ordering service to docker swarm. Also generates the genesis system channel block, genesis application and anchor transactions for the first application test channel called **`appchannel`**
- Playbook: `102.deploy_peers`
    - Execute: `ansible-playbook -v 102.deploy_peers -u root`
    - Deploys the peer services to docker swarm. Creates the application `appchannel` and joins each peer to this channel. Also updates the channel with the anchor peer transaction
- Playbook: `103.deploy_cli`
    - Execute: `ansible-playbook -v 103.deploy_cli -u root`
    - Contains mounts of MSPs for all agents (admin, orderer, peers, ...)
    - Can perfrom any and all operations on the blockchain by changing its profile to any of the mounted agents
    - Mounts a test chaincode under `/root/CLI/chaincodes/test_chaincode`
    - Sanity Check the working of the cluster
      - Install, Instanciate and Test Chaincode
        ```
        docker exec -it <<CLI_ID>> bash
        CORE_PEER_ADDRESS=peer2:7051
        CORE_PEER_MSPCONFIGPATH=/root/admin/msp
        CORE_PEER_TLS_ROOTCERT_FILE=/root/${PEER2_HOST}/tls-msp/tlscacerts/tls-${TLSCA_HOST}-7054.pem
        ```
      - Install the chaincode on peer 2
      ```CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode install -n testcc -v 1.0 -l node -p /root/CLI/chaincodes/test_chaincode/node```

      - Instanciate the chaincode
      ```CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode instantiate -C appchannel -n testcc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -o ${ORDERER_HOST}:7050 --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}```
      - GET
      ```CORE_PEER_ADDRESS=peer2:7051 CORE_PEER_MSPCONFIGPATH=/root/peer2/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode query -C appchannel -n testcc -c '{"Args":["query","a"]}'```
      - PUT
      ```CORE_PEER_ADDRESS=peer2:7051 CORE_PEER_MSPCONFIGPATH=/root/peer2/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode invoke -C appchannel -n testcc -c '{"Args":["invoke","a","b","10"]}' --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}```
      - GET
      ```CORE_PEER_ADDRESS=peer2:7051 CORE_PEER_MSPCONFIGPATH=/root/peer2/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode query -C appchannel -n testcc -c '{"Args":["query","a"]}```
