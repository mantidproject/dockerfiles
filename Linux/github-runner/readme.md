# Docker image for Mantid GitHub self-hosted runner

This is a Docker image that registers a machine as a GitHub self-hosted runner in the mantidproject/mantid repository.
The Docker image is based on the same Alma9 development image that is used in the jenkins-agent image.

### GitHub token for runner registration
You will need to create a fine-grained GitHub token with the following options:
- resource owner: mantidproject
- repository access: Only select repositories (select mantidproject/mantid)
- permissions: Administration (Read and write)

See [here](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository--fine-grained-access-tokens) for reference.

### Manually deploying a docker container
The ``start.sh`` script inside the docker image requires the following variables to be passed when creating a docker container:
- ``GITHUB_TOKEN``: see above
- ``ORGANIZATION``: normally ``mantidproject``, unless you are testing on a fork
- ``REPOSITORY``: normally ``mantid``
- ``RUNNER_NAME``: the name used in GitHub to identify the runner
They can be passed at the time of creating the docker container by running the following:
```sh
docker run -d -e ORGANIZATION='mantidproject' -e GITHUB_TOKEN=<github_token> -e REPOSITORY='mantid' -e RUNNER_NAME='my_runner_name' ghcr.io/mantidproject/github-runner-alma9:0.2
```

### Using Ansible to provision runners on the STFC Cloud
Follow the steps below to provision a set of GitHub runners (this avoids having to manually deploy the docker images).
- Create machines on OpenStack.
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
