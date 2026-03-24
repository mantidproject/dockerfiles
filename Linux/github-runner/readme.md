# Docker image for Mantid GitHub self-hosted runner

This is a Docker image that registers a machine as a GitHub self-hosted runner in the mantidproject/mantid repository.
The Docker image is based on the same Alma9 development image that is used in the jenkins-agent image.

### GitHub token for runner registration
In order to generate runner registration tokens on the fly, you will need to create a [fine-grained GitHub token](https://github.com/settings/personal-access-tokens/new) with the following options:
- resource owner: mantidproject
- repository access: Only select repositories (select mantidproject/mantid)
- permissions: Administration (Read and write)

See [here](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository--fine-grained-access-tokens) for reference and instructions for generating a registration token.

### Manually deploying a docker container
The ``start.sh`` script inside the docker image requires the following variables to be passed when creating a docker container:
- ``REG_TOKEN``: runner registration token, which can be generated using the above GitHub API token or manually via the GitHub user interface.
- ``ORGANIZATION``: normally ``mantidproject``, unless you are testing on a fork
- ``REPOSITORY``: normally ``mantid``
- ``RUNNER_NAME``: the name used in GitHub to identify the runner
They can be passed at the time of creating the docker container by running the following:
```sh
docker run -d -e ORGANIZATION='mantidproject' -e REG_TOKEN=<github_token> -e REPOSITORY='mantid' -e RUNNER_NAME='my_runner_name' ghcr.io/mantidproject/github-runner-alma9:0.5
```

### Using Ansible to provision runners on the STFC Cloud
Follow the steps below to provision a set of GitHub runners. The ansible playbook will handle the registration token generation and docker container deployment for you.
- Create machines on OpenStack (we currently use the l6.c32 flavour with Ubuntu 22.04).
- Create a fine-grained GitHub token as above.
- Navigate to the ansible directory.
- Create inventory file containing the IP address and runner name for as many nodes as you require. Use the same names as on OpenStack for consistency.
```ini
[all]
ip_address_or_hostname runner_name=NAME_OF_GITHUB_RUNNER_1
ip_address_or_hostname runner_name=NAME_OF_GITHUB_RUNNER_2
```
- Run:
```sh
export GITHUB_TOKEN=<github token goes here>
ansible-playbook -i inventory.txt github-runner.yml -u <FedID> -K --key-file <path to your STFC cloud key>
```
- If prompted for password, enter your key password (not FedID password)
- Once the playbook has completed, runners should appear [here](https://github.com/mantidproject/mantid/actions/runners?tab=self-hosted)
