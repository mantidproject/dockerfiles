# External Data Mirror Deployment

This allows for additional copies of the external data to be generated to reduce the load
on the main server. 

Developers deploying these playbooks will require ssh access to `mantidproject.org`.

## Setup

- Provision a new linux virtual machine (VM) (on OpenStack at STFC) with an ssh key that 
  you have on your system.
- Add the `HTTP` security group to the instance.
- Create an `ansible` conda environment:

```sh
mamba create -n ansible ansible
mamba activate ansible
```

- Install 3rd party ansible packages from `ansible-galaxy`:

```sh
ansible-galaxy install -r requirements.yml
```

- Create an `inventory.txt` file in the following format:

    - `VM_IP_ADDRESS`: IP address of the node you just provisioned. 
    - `IP_TO_COPY_FROM`: IP address or domain (usually `mantidproject.org`) that holds 
      the external data you want to copy.
    - `DIR_NAME`: The directory in the `/srv/` directory on the server that holds the 
      rest of the path to the external data. On `mantidproject.org` this is formatted 
      as the main server's IP.

```ini
[all]
<VM_IP_ADDRESS> main_server_hostname=<IP_TO_COPY_FROM> main_data_srv_dir=<DIR_NAME>
```

## Deployment

- Deploy the playbook to the list of machines in the inventory.

```sh
ansible-playbook -i inventory.txt external-data-mirror.yml -u <YOUR_VM_USERNAME> -K
```

- There are 3 tags for the different parts of the deployment:

  - `setup`: Sets up the VM with ssh keys for the whole DevOps team and a docker 
    installation.
  - `mirror`: Creates a copy of the data on the new VM and sets up a crontab job to keep 
    it in sync with any new data added on the main server.
  - `server`: Spins up a docker container to host the server with a mounted volume
    containing the copied data.

The new server can now be accessed by: `http://<VM_IP_ADDRESS>/external-data/MD5/<TEST_FILE_HASH>`

### Configuring the Load Balancer (STFC Cloud)

For the mantid build process to be able to access your new mirror, it needs to be added to the
load balancer pool.


- Navigate to `Network` &rarr; `Load Balancers` &rarr; `External Data LB` &rarr; `Pools` &rarr; 
 `HTTP Pool` &rarr; `Members` &rarr; `Add/Remove Members`.
- Add your new VM to this pool and set the port to `80` (HTTP).
- Your new node should now be accessible via the floating IP address of the load balancer.
