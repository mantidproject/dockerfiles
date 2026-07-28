# Self-hosted Windows Github actions runner setup
This document provides instructions for setting up a self-hosted Windows github actions runner.

## Connecting to the windows cloud virtual machine

1. All the existing self-hosted runners are available [here](https://github.com/mantidproject/mantid/actions/runners?tab=self-hosted)
2. Press `Windows key` + `R`. Type in `MSTSC` and hit `Enter` to open `Remote Desktop Connection`.
3. In the `Computer` field type the name of the cloud virtual machine, for example `isiscloudwin1.isis.cclrc.ac.uk`.
4. For the `Username` use your 03 username as `CLRC\<fedid>03`.
5. Upon clicking `Connect` you will be prompted to enter your 03 password.
6. If you have successfully established a remote connection to the virtual machine, a windows desktop will be opened in a new window.

## Docker image for Mantid GitHub self-hosted runner (Windows)

This is a Docker image that registers a Windows machine as a GitHub self-hosted runner in the mantidproject/mantid repository.
The Docker image is based on the same Windows Server Core base and build tools used in the jenkins-node image.

## Building the image

From the `Windows/github-runner/` directory of this repo, run:
```powershell
docker build -f Win.Dockerfile -t ghcr.io/mantidproject/github-runner-win:<image_version> .
```

## Pushing the image to the registry

1. Log in to the GitHub Container Registry first
```powershell
docker login ghcr.io -u <github_username> -p <github_token>
```
2. Then push the image
```powershell
docker push ghcr.io/mantidproject/github-runner-win:<image_version>
```

## GitHub token for runner registration
In order to generate runner `registration tokens` on the fly, you need to have admin priviledges of the mantid repo and you need to create a [fine-grained GitHub token](https://github.com/settings/personal-access-tokens/new) with the following options:
- resource owner: `mantidproject`
- repository access: `Only select repositories` (select `mantidproject/mantid`)
- permissions: `Administration (Read and write)`

See [here](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository--fine-grained-access-tokens) for reference and instructions for generating a `registration token`. Please note that the `registration token` is only valid for limited time ~10 Mins and should be used for `REG_TOKEN` as shown below.

## Manually deploying a docker container
The `start.ps1` script inside the docker image requires the following variables to be passed when creating a docker container:
- `REG_TOKEN`: runner registration token, which can be generated using the above GitHub API token or manually via the GitHub user interface.
- `ORGANIZATION`: normally `mantidproject`, unless you are testing on a fork
- `REPOSITORY`: normally `mantid`
- `RUNNER_NAME`: the name used in GitHub to identify the runner

They can be passed at the time of creating the docker container by running the following command from a `PowerShell` with admin rights on the Windows host or, by selecting `Tools->Windows PowerShell` from Windows Server Manager dashboard. For the `name` and `RUNNER_NAME`, please follow the naming convention as `isis-github-runner-win-<number>`. 
Ex: `isiscloudwin1` -> `isis-github-runner-win-1`.

```powershell
docker run -d `
  --name <my_runner_name> `
  --restart unless-stoppped `
  -e ORGANIZATION='mantidproject' `
  -e REPOSITORY='mantid' `
  -e RUNNER_NAME='<my_runner_name>' `
  -e REG_TOKEN=<registration_token> `
  ghcr.io/mantidproject/github-runner-win:<image_version>
```
