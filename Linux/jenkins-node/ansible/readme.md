# Ansible Scripts for Mantid Jenkins Agents

New Linux nodes for use on Jenkins are now set up using ansible scripts in this folder.

## Setting up cloud nodes

- Ensure you have activated a conda environment with ansible (you may need to use the conda environment set up for use with the ansible-linode repo)
- set up a new node on Jenkins (this will give you the secret code)
- navigate to the [`Ansible folder`](https://github.com/mantidproject/dockerfiles/tree/main/Linux/jenkins-node/ansible)
- Update the `inventory.txt` file with the IP address, agent name and agent secret (i.e. Jenkins secret code). Be sure to save this file when update complete!
- If creating staging nodes, update the `jenkins-agent-staging.yml` file to specify the correct `jenkins_url`, and `jenkins_identity` variables. To get the `jenkins_identity` use the following command in the jenkins console: `hudson.remoting.Base64.encode(org.jenkinsci.main.modules.instance_identity.InstanceIdentity.get().getPublic().getEncoded())`.
- Run the following command, replacing `staging` with `production` if appropriate and replacing `FedID` with your FedID.
```
ansible-playbook -i inventory.txt jenkins-agent-staging.yml -u FedID -K
```
- you will be asked for a password - enter your FedID password
- when ansible script is complete check that node is now live on Jenkins with appropriate labels


## Cleaning nodes

Before cleaning any nodes mark them temporarily offline on Jenkins and ensure no jobs are running on them before cleaning.

The easiest way to clean nodes is using a groovy script on Jenkins. Use the links below for guidance
- [`Remove directories across multiple nodes`](https://developer.mantidproject.org/JenkinsConfiguration.html#remove-directories-across-multiple-nodes)
- [`Remove directories from single node`](https://developer.mantidproject.org/JenkinsConfiguration.html#remove-directories-from-single-node)

If this does not work you may need to spin up a new docker container. Use the instructions for Changing docker image below.

## Changing docker image

If you need to update the docker image or spin up a new docker container on a Linux machine - follow these instructions. Before starting mark any nodes you will be changing as temporarily offline on Jenkins and ensure no jobs are running on them. 

- ssh into the node
- Stop and remove the container using the following command, replacing machinename with the appropriate name e.g. `isis-cloud-linux-1`
```
docker stop machinename && docker rm machinename
```
- Remove any associated volumes using the following command, again replacing machinename with the appropriate name
```
docker volume rm machinename
```
- for cloud machines, close the ssh connection and follow the instructions for setting up cloud nodes above.
- for physical machines navigate to the folder that contains the `deploy.sh` script. This is normally `dockerfiles/jenkins-node/bin`.
- Run the following command (you may be able to find it using reverse search)
```
./deploy.sh machinename agent_secret "https://builds.mantidproject.org" latest 50G
```
- on success close the ssh connection and check node connects on Jenkins

