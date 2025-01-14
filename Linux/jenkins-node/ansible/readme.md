# Ansible Scripts for Mantid Jenkins Agents

New Linux nodes for use on Jenkins are now set up using ansible scripts in this folder.

## Setting up cloud nodes

- Ensure you have activated a conda environment with ansible (you may need to use the conda environment set up for use with the ansible-linode repo).
- Set up a new node on Jenkins. The easiest way to set up a jenkins node is to copy an existing node: From the jenkins menu, select `New Item`, type in the name for your node, then scroll down to the `copy from` box and enter the node name you wish to copy.
- To get the secret for your newly set up node, select your new node from the `Build Executor Status` pane on the left hand side of the jenkins home page. The secret should be displayed as part of the command in the box below `Run from agent command line:`. Note, if you are setting up a node directly on the staging server you will have to use the following command in the jenkins console (`<jenkins_url>/script`) to obtain the secret:
```java
jenkins.model.Jenkins.getInstance().getComputer("<jenkins node name>").getJnlpMac()
```
- navigate to the [`Ansible folder`](https://github.com/mantidproject/dockerfiles/tree/main/Linux/jenkins-node/ansible)
- Update the `inventory.txt` file with the IP address, agent name and agent secret (i.e. Jenkins secret code). Be sure to save this file when update complete!
- If creating staging nodes, update the `jenkins-agent-staging.yml` file to specify the correct `jenkins_url`, and `jenkins_identity` variables. To get the `jenkins_identity` use the following command in the jenkins console: 
```java
hudson.remoting.Base64.encode(org.jenkinsci.main.modules.instance_identity.InstanceIdentity.get().getPublic().getEncoded())
```
- Run the following command, replacing `staging` with `production` if appropriate and replacing `FedID` with your FedID.
```sh
ansible-playbook -i inventory.txt jenkins-agent-staging.yml -u FedID -K
```
- you will be asked for a password - enter your FedID password
- when ansible script is complete check that node is now live on Jenkins with appropriate labels

### Ansible tags

When running the `jenkins-agent-staging.yml` or `jenkins-agent-production.yml` playbooks, two tags are provided: `initial-setup` and `agent`. These tags allow you to perform sequences of roles in isolation.
- `initial-setup`: roles tagged with the `initial-setup` tag install required packages and configure the host machine upon which the agent will be run.
- `agent`: roles tagged with the `agent` tag deploy the docker container that constitutes the jenkins agent.

To use a tag, you pass it in to the `ansible-playbook` command with the `-t` flag. For example, if you have already set up the host machine and just want to deploy a jenkins agent:
```sh
ansible-playbook -i inventory.txt jenkins-agent-staging.yml -u FedID -K -t agent
```

## Cleaning nodes

- Before cleaning any nodes mark them temporarily offline on Jenkins and ensure no jobs are running on them before cleaning.

- Update the `inventory.txt` file as above, including only the nodes you intend to clean.

- The tasks in the cleaning playbook make use of tags to restrict what is cleaned:

  - `pr`: Pull Requests.
  - `nightly`: Nightly deployments for main and release next.
  - `package`: Build Packages from Branch
  - `docs`: Docs build and publish.  

- Run the following with the desired tags (which use a comma-separated list):
```sh
ansible-playbook -i inventory.txt clean-jenkins-agents.yml -u FedID -K -t pr,nightly,package,docs
```

- Set the nodes you shut down back online.

### Troubleshooting

- If this does not work you may need to spin up a new docker container. Use the instructions for Changing docker image below.

## Changing docker image

If you need to update the docker image or spin up a new docker container on a Linux machine - follow these instructions. Before starting mark any nodes you will be changing as temporarily offline on Jenkins and ensure no jobs are running on them. 

- ssh into the node
- Stop and remove the container using the following command, replacing machinename with the appropriate name e.g. `isis-cloud-linux-1`
```sh
docker stop machinename && docker rm machinename
```sh
- Remove any associated volumes using the following command, again replacing machinename with the appropriate name
```sh
docker volume rm machinename
```
- for cloud machines, close the ssh connection and follow the instructions for setting up cloud nodes above.
- for physical machines navigate to the folder that contains the `deploy.sh` script. This is normally `dockerfiles/jenkins-node/bin`.
- Run the following command (you may be able to find it using reverse search)
```sh
./deploy.sh machinename agent_secret "https://builds.mantidproject.org" latest 50G
```
- on success close the ssh connection and check node connects on Jenkins

