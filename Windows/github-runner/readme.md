# Docker image for Mantid GitHub self-hosted runner (Windows)

This is a Docker image that registers a Windows machine as a GitHub self-hosted runner in the mantidproject/mantid repository.
The Docker image is based on the same Windows Server Core base and build tools used in the jenkins-node image.

### GitHub token for runner registration
In order to generate runner registration tokens on the fly, you will need to create a [fine-grained GitHub token](https://github.com/settings/personal-access-tokens/new) with the following options:
- resource owner: mantidproject
- repository access: Only select repositories (select mantidproject/mantid)
- permissions: Administration (Read and write)

See [here](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository--fine-grained-access-tokens) for reference and instructions for generating a registration token.

### Manually deploying a docker container
The `start.ps1` script inside the docker image requires the following variables to be passed when creating a docker container:
- `REG_TOKEN`: runner registration token, which can be generated using the above GitHub API token or manually via the GitHub user interface.
- `ORGANIZATION`: normally `mantidproject`, unless you are testing on a fork
- `REPOSITORY`: normally `mantid`
- `RUNNER_NAME`: the name used in GitHub to identify the runner

They can be passed at the time of creating the docker container by running the following from PowerShell on the Windows host:
```powershell
docker run -d -e ORGANIZATION='mantidproject' -e REG_TOKEN=<github_token> -e REPOSITORY='mantid' -e RUNNER_NAME='my_runner_name' ghcr.io/mantidproject/github-runner-win:0.1
```

### Using Ansible to provision runners on Windows VMs
Follow the steps below to provision a set of GitHub runners. The ansible playbook will handle the registration token generation and docker container deployment for you.

Prerequisites on the Windows host:
- Docker must be installed and running (see `Windows/jenkins-node/readme.md` for Docker installation steps).
- WinRM must be configured to allow Ansible connections.

Steps:
- Create a fine-grained GitHub token as above.
- Navigate to the ansible directory.
- Install required Ansible collections:
```sh
ansible-galaxy collection install -r requirements.yml
```
- Create an inventory file with the IP addresses and runner names of your Windows VMs:
```ini
[all]
ip_address_or_hostname runner_name=NAME_OF_GITHUB_RUNNER_1
ip_address_or_hostname runner_name=NAME_OF_GITHUB_RUNNER_2
```
- Run:
```sh
export GITHUB_TOKEN=<github token goes here>
ansible-playbook -i inventory.txt github-runner.yml \
  -e "ansible_connection=winrm" \
  -e "ansible_winrm_transport=ntlm" \
  -u <username> -k
```
- Once the playbook has completed, runners should appear [here](https://github.com/mantidproject/mantid/actions/runners?tab=self-hosted)
