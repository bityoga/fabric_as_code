# fabric_as_code
Provisioning and Spawning a Hyperledger Fabric on Docker Swarm
Required Ansible Version: **2.8.4**
Required Python Version: **3.7+**

## Provisioning infrastructure from Digital Ocean (DO)
- Playbook: **001.spawn_droplets.yml**
- Change **inventory/hosts_template**
- Each hlft* represents a machine/VM that would be created

- These names and numbers of machines should be altered to suit your requirements.
  - any changes  chould also be reflected in **001.spawn_droplets.yml**
  - in purticular the following params has to be changed
    - oauth_token: your token to connect to DO. [bitYoga team uses the specified token and doesnt need to change] 
    - ssh_keys: Insert you ssh key into this array, so that your local machine can ssh into DO. 
      - *Note: Your public key must be registered with DO*
      - If it is registered, the ssh_keys can be retrieved by executing on the terminal
        - curl -X GET -silent "https://api.digitalocean.com/v2/account/keys" -H "Authorization: Bearer 2c7eab4408ccb4f5805e68030f0482f1f2120ed6e9c04e11bb9b227b58d0fbef" 
        - "Authorization: Bearer" is the key for bitYoga and should not be shared with anyone else. bitYoga team can use it
    - loop: The number of loop items should reflect the number of machines defined in **inventory/hosts_template**
      - name: The name should be exactly same as in **inventory/hosts_template**
      - image: Ubuntu images is ID **52473856** and CentOS images has ID **50903182**
        - Additional images IDS can be retrived by running the command on terminal
          - curl -X GET -silent "https://api.digitalocean.com/v2/images?per_page=999" -H "Authorization: Bearer 2c7eab4408ccb4f5805e68030f0482f1f2120ed6e9c04e11bb9b227b58d0fbef" | grep --color -E "ubuntu"
          - "Authorization: Bearer" is the key for bitYoga and should not be shared with anyone else. bitYoga team can use 
          - "ubuntu" can be changed with any other distro name and it will be highlighted in the returned results
- Example changing **inventory/hosts_template** to spawn a 3 machine cluster
```yaml
[debian]
t1  ansible_python_interpreter="/usr/bin/python3.5"
t2  ansible_python_interpreter="/usr/bin/python3.5"

[redhat]
t3 ansible_python_interpreter="/usr/bin/python2.7"

[all:children]
swarm_manager_prime
swarm_managers
swarm_workers

[swarm_manager_prime]
t1  ansible_python_interpreter="/usr/bin/python3.5"

[swarm_managers]
t1  ansible_python_interpreter="/usr/bin/python3.5"

[swarm_workers]
t2 ansible_python_interpreter="/usr/bin/python3.5"
t3 ansible_python_interpreter="/usr/bin/python2.7"
```
- Relevent changes in **001.spawn_droplets.yml** 
```ansible
...
...
...
  .....
    .....
    .....
    ssh_keys: [20711668, 25140548, **12345**] # New ssh_key id. Must be already registered in DO    
    .....
    .....
  .....
  loop:
    - {name: "t1", image: "52473856", region: "lon1", size: "s-1vcpu-1gb"} # Ubuntu 16.04.6 (LTS) x64
    - {name: "t2", image: "50903182", region: "fra1", size: "s-1vcpu-1gb"} # CentOS 7.6 x64
    - {name: "t3", image: "52473856", region: "fra1", size: "s-1vcpu-1gb"} # Ubuntu 16.04.6 (LTS) x64
...
...
```
- Start: **ansible-playbook -v 001.spawn_droplets.yml**

## Deprovisioning infrastructure from Digital Ocean (DO)
 - Playbook: **001.despawn_droplets.yml** deprovisions the infrastructure that was spawned earlier
 - Start: **ansible-playbook -v 001.despawn_droplets.yml**

## Persistent Storage Initialization
- Playbook: **010.init.mount.yml** provide a persistent storage for for your services.
- Start: **ansible-playbook -v 010.init.mount.yml -u root**

## Prepare the spawned machines on DO.
- Playbook: **011.initialize_hosts.yml** Install required pre-req., setup docker and create relevent users for the services
- Start: **ansible-playbook -v 011.initialize_hosts.yml -u root**

## Service images prep
- Playbook **012.prepare_docker_images.yml** pull docker images relevent for your services and update them as per your service requirements
- Start: **ansible-playbook -v 012.prepare_docker_images.yml -u root**

## Mount FS
- Playbook: **013.mount_fs.yml** Mount the FS for persistent storage of services on each host machine spawned up in DO
- Start: **ansible-playbook -v 013.mount_fs.yml -u root**

## Spawn Swarm
- Playbook: **014.spawn_swarm.yml** spin up a docker swarm as described in your *inventory/hosts_template* file
- Start: **ansible-playbook -v 014.spawn_swarm.yml -u root**

## Deploy CA
- Playbook: **100.deploy_ca.yml** deploys ca services: 
  - RCA - to certify Intermediate CAs
  - AICA - to certify other services (agents) running in the network
  - UICA - to certify users that would use the network / daap
- Start: **ansible-playbook -v 100.deploy_ca.yml --flush-cache -u root**

## Deploy Ordering Service
- Playbook: **101.deploy_orderer.yml**, created a one organization Orderer service
- Start: **ansible-playbook -v 101.deploy_orderer.yml --flush-cache -u root**

## Deploy Peer Services
- Playbook: **102.deploy_peers.yml** spins up 3 peers with different roles for one Organization
  - EPEER: Endorser peer. **Chaincodes should be only installed on it**
  - CPEER: Committer peer. Receives confirmed transactions and blocks from the ordering services. It is also responsible to sync the newly recieved blocks with the other peers in the organization
  - APEER: Anchor Peer is the endpoint for other anchor peers from different organizations withing the BLockchain application consortium to connect and sync with.
- Start: **ansible-playbook -v 102.deploy_peers.yml --flush-cache -u root**

## Installing Chaincode:
    - Log into the CLI service in the docker swarm
    - set the following env vars to work with the Endorser peer
```bash
CORE_PEER_LOCALMSPID=bityoga
CORE_PEER_TLS_ENABLED=false
CORE_PEER_ADDRESS=$CPEER_HOST:7054
CORE_PEER_MSPCONFIGPATH=/home/$EPEER_HOST/msp

FABRIC_CFG_PATH=/home/$EPEER_HOST
```
    - Next run
```
peer chaincode ..
(OR)
CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS peer chaincode ...
```
    - for more details on chaincode refer to mysome_code repo