# Registar Server for fabric-as-code (HTTPS Enabled)
The register service is an **optional** service provided for the fabric as code hyperledger fabric network. This service provides a RESTful App for registration of users. This purticularly useful for mobile Hyperledger Fabric clients that would like to call a registration service with admin rights that is able to register a given user.

## Pre-requisites
- Make sure that the the fabric-as-code is up and running
- You have to run the playbook '200.deploy_ registrar_service.yml' on the master node of the fabric-as-code network
- Change the file **inventory/hosts** in this directory
  - Please replace the *ip.address* value in the following line inside *inventory/host* to the ip address of the machine running the master node
    ```hlf1 ansible_host=ip.address ansible_python_interpreter=/usr/bin/python3```
- Change the file **group_vars/all.yml** in this directory
  - Change the following two values
    - ```admin_name```: name of the user with admin rights that can register new client users. **Note: This user needs to have been already been registered with the hyperledger fabric network**
    - ```admin_password```: password of the aforementioned user
- Make sure port **8088** is open for the master node of the hyperledger fabric network

## Start the service
- Inorder to start the service run the following command
- Make sure that the machine form which you are running the following commands, has ansible version of atleast **ansible 2.9.1** or up. 
- !!!Required: Ensure that you have password less SSH for these host for a user. Later when you run the playbooks change the value for the playbooks with argument -u to the appropiate user that has passwordless SHH access to these machines
- 200.deploy_ registrar_service.yml: Playbook that runs the registration services
```ansible-playbook -v 200.deploy_ registrar_service.yml -u root```

## Varification
- Test connection: *curl -k -X POST https://165.232.76.37:8088*
- Register a user: *curl -k -X POST -d "username=user1&password=user1pw" https://165.232.76.37:8088/register*
  - Change the value for username or password