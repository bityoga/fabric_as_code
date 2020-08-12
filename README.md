# Fabric as Code
The current project enables provisioning of Hyperledger Fabric (HLF) [https://www.hyperledger.org/projects/fabric] cluster over a host of machines managed by Docker Swarm [https://docs.docker.com/engine/swarm/]. 

It offers an easily configurable mechanism for creating custom Hyperledger Fabric Blockchain deployment arcitecture.

Current Blockchain as a Service offerings from IBM, Amazon, Microsoft or others tie you and your consortium to their infrastructure and ecosystem. The presented solution is cloud agnostic and can be deployed over any cloud provider or private data centers. Each organization that part of your blockchain can therefore choose their own infrastructure provider and by using the fabric-as-code solution can seamlessly deply a Hyperledger Fabric Blockchain.

Currently it support the spinning up of HLF cluster for just one organization, however, we are worrking towards mechanism for easily adding new organization to an exisiting cluster. 

Please see the Overview and TODO sections bellow

## Overview
- Hyperledger Fabric (HLF) v2.2 LTS
- Cloud Deployment
- Docker Swarm used for orchestration
- Redundency, High Availability and Scalability of HLF services
- Services:
  - Certificate Authorities (CA)
    - Organizational CA
    - TLS CA
  - Orderer
    - RAFT
  - Peers
    - Configurable number of peers
    - Chaincode support V1.X
    - Support for both CouchDB and LevelDB databases
  - TLS enabled for all services
  - Persistent Filesystem for all services
- Single Org Setup
- Single Sys
- Single App channel setup
## Todo
- PostGres support for CAs
- Add new Organization to consortium
  - System channel 
  - Application channel
- Update consortium
  - System channel 
  - Application channel
- Add new Application Channel
- Update existing Application Channel
- Customizable Policies
  - System Channel
  - Application Channel
  - Endorsement Channel
- Mutual TLS
- Deployment User Interface

## Pre-requisites: 
- Ensure that you have installed **ansible** version 2.9.x on your **local machine**. Please see [https://www.ansible.com/] for further details on installing ansible on your local machine.
Once ansible is installed, you can verify its version using the command `ansible --version` on you bash shell. You should receive an output such as this:

```
ansible 2.9.1
config file = /Users/antorweep/Documents/dev/mysome_glusterfs/ansible.cfg
configured module search path = ['/Users/antorweep/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
executable location = /usr/local/bin/ansible
python version = 3.7.4 (default, Jul  9 2019, 18:13:23) [Clang 10.0.1 (clang-1001.0.46.4)]
```

- Gluster FS  is used as persistent storage for all docker services hosted by an organization. In is required to have a seperate GlusterFS cluster in order to run this project on each of the **remote machines** that will host the HLF. We have created an easily deployable package for creating a GlusterFS cluster. Please check: [https://github.com/bityoga/mysome_glusterfs] and follow the ReadMe there!

## Configuration
There are very few parameters to be configured currently. All configurations are made inside *group_vars/all.yml*. 
  - **GlusterFS Setup** !Required
    - `gluster_cluster_volume` specifies the name of the created glusterfs volume. It should be the same value as the one used for creating the GlusterFS cluster. See pre-requisites step #2 about GlusterFS    
  - **config vars** [Optional]
    - Under the section *Hyperledger Fabric Network config vars*, there are various values for your organization and credentials of the agents and services running within you HLF cluster for your organization. 
    - You may choose the change them to more secure values
  - ** CAs ** [Optional]
    - This projects spins up two CAs
      - ORGCA: Generates the MSPs for the agents (peers, agents, clients, users, admins) to interact with the Blockchain Network
      - TLSCA: Generates the MSPs for the agents (peers, agents, clients, users, admins) to estabilsh TLS communication with themselves or with the outside world. 
    - You may choose the change the number of *replicas* hosted by Docker Swarm or the database used by the CA (default: SQLITE) to Postgres or MySQL. 
      - **Note: Postgres or MySQL is not supported as of now**
  - ** Orderer ** [Optional]
    - This projects spins up one Ordering service for each organization
    - The only supported concensus protocal is **RAFT**    
    - You may choose the change the number of *replicas* depending on your requirements to improve scalability, redundency and availability of the service
  - ** Peers **  [Optional]
    - By default two peers are created. 
      - Peer1: Is the Anchor peer that will connect with other organization
      - Peer2- Is the endorser peer which will have the chaincode installed
    - However, as many number of peers can be created by changing the following configuration values
      - Under *# Creds of various agents* section in *group_vars/all.yml* add a new entry for the peer user name and password. We show an example for adding peer3
      ```json
      peer3_user: "peer3"
      peer3_password: "peer3pw"
      ```
      - Under *Peers* section in *group_vars/all.yml* add a new entry for a peer. We show an example of how to add the third peer bellow:
      ```json
      peer3: { switch: "on", image: "hyperledger/fabric-peer", tag: "2.2", replicas: -1, port: 8054, 
      caname: "{{orgca.name}}", path: "/root/{{peer3_user}}", bootstrap: "",
      dbtype: "goleveldb",
      name: "{{peer3_user}}", password: "{{peer3_password}}", type: "peer",
      leader: "{peer1_user}}"
      }
      ```
     - Under *Service Summary* section in *group_vars/all.yml* add a new entry for a peer into **peerservices**. We show an example of how to add the third peer bellow:
      ```json
      peerservices:
        - "{{peer1}}"
        - "{{peer2}}"
        - "{{peer3}}
      ```    
    - You may choose the change the number of *replicas* for each of to peers, depending on your requirements to improve scalability, redundency and availability of the service

## Defining the remote host machines
In order to set up hlf cluster we would need a set of host machines. Ansible will comunicate with these machines and setup your cluster.

### Configuring connection to remote machine
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
- Make a copy of this file as `inventory/hosts`
- In order the specify the host machines, you need to populate this file `inventory/hosts` with the names of the host that you want to create. Each line/row in the file would represent a host machine. The lines with square brackets  `[]` represents groups for internal reference in the project and **must not be changed**. Please fill each line under a group in the format: 

`hostname ansible_host=remote.machine1.ip.adress  ansible_python_interpreter="/usr/bin/python3"`

  - `hostname`: can be any name. Must be unique for each machine. The project will internally refer to the machines with this name
  - `ansible_host`: the ip address of the remote host. This machine should be accessable over the network with this ip address
  - `ansible_python_interpreter`: In order for ansible to work, we need python 2.7.x or above available on each remote machine. Here we specify the **path of python on the remote machine** so that our local ansible project know where to find python on these machines.
- The following *example* defines 5 machines as remote hosts
```
[all:children]
swarm_manager_prime
swarm_managers
swarm_workers

[swarm_manager_prime]
hlf0 ansible_host=147.182.121.59 ansible_python_interpreter=/usr/bin/python3

[swarm_managers]
hlf0 ansible_host=147.182.121.59 ansible_python_interpreter=/usr/bin/python3
hlf1 ansible_host=117.247.73.159 ansible_python_interpreter=/usr/bin/python3

[swarm_workers]
hlf2 ansible_host=157.245.79.195 ansible_python_interpreter=/usr/bin/python3
hlf3 ansible_host=157.78.79.201 ansible_python_interpreter=/usr/bin/python3
hlf4 ansible_host=157.190.65.188 ansible_python_interpreter=/usr/bin/python3
```
- **!!!Required: Ensure that you have password less SSH for these host for a user. Later when you run the playbooks change the value for the playbooks with argument -u to the appropiate user that has passwordless SHH access to these machines**

## Setting up HLF
Setting up of hyperledger fabric cluster requires the following steps. Creating the infrastructure with all dependencies installed and starting the hlf services in all the host machines. Finally, there is also mounting the glusterfs point.

- **!!!In our case the user root has passwordless SSH access to all the remote machines. In your case, it its different, please change the value for the argument -u to the appropiate user.**

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
- Playbook: `015.deploy_swarm_visualizer.yml`
    - Execute: `ansible-playbook -v 015.deploy_swarm_visualizer.yml -u root`
    - Starts a docker swarm visualizer service.
    - The swam visualiser service will be exposed in port : **9090**
    - **Example :** Open http://167.172.189.6:9090/  (Replace Ip address with your manager's Ip address).
- Playbook: `016.deploy_portainer.yml`
    - Execute: `ansible-playbook -v 016.deploy_portainer.yml -u root`
    - Starts a portainer service.
    - The portainer service will be exposed in port : **9000**
    - **Example :** Open http://167.172.189.6:9000/  (Replace Ip address with your manager's Ip address).
    - **Set up the portainer admin password and login (Remember the admin password for future logins)**
    - **CONNECT TO PORTAINER AGENT**
       - **agent name :** "agent"
       - **end point url :** "tasks.portainer_agent:9001"
- This will list all swarm information . Almost entire swarm management is supported.
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
        ```bash
        docker exec -it <<CLI_ID>> bash
        PEER_HOST=peer2
        CORE_PEER_ADDRESS=${PEER_HOST}:7051
        CORE_PEER_MSPCONFIGPATH=/root/CLI/${ORGCA_HOST}/${ADMIN_USER}/msp
        CORE_PEER_TLS_ROOTCERT_FILE=/root/CLI/${ORGCA_HOST}/${PEER_HOST}/msp/tls/ca.crt
        ```
      - Install the chaincode on peer 2
      ```bash
      CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode install -n testcc -v 1.0 -l node -p /root/CLI/chaincodes/test_chaincode/node
      ```

      - Instanciate the chaincode
      ```bash
      CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode instantiate -C appchannel -n testcc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -o ${ORDERER_HOST}:7050 --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}
      ```

      - List the installed chaincodes
      ```bash
      CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode list --installed
      ``` 
      - List the instanciated chaincodes

      ```bash
      CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode list --instantiated -C appchannel
      ```
      - GET
      ```bash
      CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=/root/CLI/${ORGCA_HOST}/${PEER_HOST}/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode query -C appchannel -n testcc -c '{"Args":["query","a"]}'
      ```
      - PUT
      ```bash
      CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=/root/CLI/${ORGCA_HOST}/${PEER_HOST}/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode invoke -C appchannel -n testcc -c '{"Args":["invoke","a","b","10"]}' -o ${ORDERER_HOST}:7050 --tls --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}
      ```
      - GET
      ```bash
      CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=/root/CLI/${ORGCA_HOST}/${PEER_HOST}/msp CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode query -C appchannel -n testcc -c '{"Args":["query","a"]}'
      ```
      
- Playbook: `104.deploy_hlf_explorer`
    - Execute: `ansible-playbook -v 104.deploy_hlf_explorer.yml --flush-cache -u root`
    - Deploys the hyperledger explorer services to docker swarm.
    - The service will be exposed in **port : 8090**.
    - The hlf_explorer service will start 16 seconds after the hlf_explorer_db service. Try to wait for sometime and check the url **http://178.62.207.235:8090/  (Replace ip address, with your primary manager's ip address).**
    - Note : Make sure to have run 'ansible-playbook -v 012.prepare_docker_images.yml -u root' so the docker images needed for the explorer services are pulled and made ready. Else it may take some time for the services to get started.
    
    
    **Hyperledger Explorer Login Credentials**
    - **user_name : admin**
    - **password : adminpw**
    
**Troubleshoot**
Peer Restart: If at all the peer service crashes or killed, it will be automatically be restarted by the docker swarm. However, the chaincodes are not maintained by the swarm. Therefore, the existing chaincode container dies when the peer restarts. In order to bring the peer back to working order we have to first join the peer again to the channel and then just install the chaincode so that the chaincode container is started. This way you wont loose any existing data.
- Log into CLI and set env vars
  ```bash
  docker exec -it <<CLI_ID>> bash
  PEER_HOST=peer2
  CORE_PEER_ADDRESS=${PEER_HOST}:7051
  CORE_PEER_MSPCONFIGPATH=/root/CLI/${ORGCA_HOST}/${ADMIN_USER}/msp
  CORE_PEER_TLS_ROOTCERT_FILE=/root/CLI/${ORGCA_HOST}/${PEER_HOST}/msp/tls/ca.crt
  ```

- Join the peer to the application channel
```bash
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH peer channel join -b /root/${AGENT_HOST}_cli/artifacts/appchannel.block
```
- Install the chaincode again
```bash
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode install -n testcc -v 1.0 -l node -p /root/CLI/chaincodes/test_chaincode/node
```
- Run the QUERY and INVOKE commands from above to verify

  **File Configuration Explanations**

  - All 'hlf_explorer' config files will be available under the directory "root/hlf-explorer/" , in the primary manager.
  - "/root/hlf-explorer/pgdata" - is used as mount directory for hlf_explorer_db (Postgresql) service
  - "/root/hlf-explorer/wallet" - is used as the wallet directory for the hlf_explorer service
     - Both of these directories are in the primary manager as the services are started only in primary manager. .
     - This can be modified to a shared mount point, if the services are later planned to run different machines in the swarm.
  - In hlf_explorer_db,
        - "/docker-entrypoint-initdb.d/createdb.sh" and
        - "/docker-entrypoint.sh" are modified as the original scripts in the images were not starting properly.
  - The network config file for the hlf_explorer is configured with the prime manager's ip addressees.

  **Service Configuration Explanations**

  - The current commit, specifies all the explorer services to be started as swarm services in the prime manager.
     - Both of the services 1) hlf_explorer_db(Postgresql db) and 2) hlf_explorer are started in the prime manager.

  - The playbook also supports deploying the hlf_explorer services using a docker compose file (and) docker stack deploy
      - This features are commented out currently. Only swarm service deployment is enabled in this commit.
      - However a docker-compose.yaml to deploy the hlf_explorer service is templated and configured dynamically for additional support.
      - This file will be available in the "root/hlf-explorer/hlf-explorer-docker-compose.yaml" in the prime manager machine.
