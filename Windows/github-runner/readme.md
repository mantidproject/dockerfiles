# Docker image for Mantid GitHub self-hosted runner (Windows)

This is a Docker image that registers a Windows machine as a GitHub self-hosted runner in the mantidproject/mantid repository.
The Docker image is based on the same Windows Server Core base and build tools used in the jenkins-node image.

### Building the image

From the `Windows/github-runner/` directory, run:
```powershell
docker build -f Win.Dockerfile -t ghcr.io/mantidproject/github-runner-win:<image_version> .
```

### Pushing the image to the registry

Log in to the GitHub Container Registry first, then push:
```powershell
docker login ghcr.io -u <github_username> -p <github_token>
docker push ghcr.io/mantidproject/github-runner-win:<image_version>
```

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
docker run -d `
  --name <my_runner_name>
  -e ORGANIZATION='mantidproject' `
  -e REPOSITORY='mantid' `
  -e RUNNER_NAME='my_runner_name' `
  -e REG_TOKEN=<github_token> `
  ghcr.io/mantidproject/github-runner-win:<image_version>
```
