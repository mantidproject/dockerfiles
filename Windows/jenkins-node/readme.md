# Cloud Windows Jenkins Node Setup

This document provides instructions for setting up a cloud Windows Jenkins node on a cloud hosted virtual machine running the `Windows Server 2019` OS.

## Permissions

Before setting up a cloud Windows Jenkins node, you will need to have the following permissions. If you do not have any of these permissions, please contact a member of the RAL Mantid Devops team.

- Admin access to the cloud Windows virtual machine to host the node.
- Admin access to Jenkins.
- Read access to the `mantidproject/dockerfiles` repository (https://github.com/mantidproject/dockerfiles).

## Connect to the windows cloud virtual machine

1. Press `Windows key` + `R`. Type in `MSTSC` and hit `Enter` to open `Remote Desktop Connection`.
2. In the `Computer` field type the name of the cloud virtual machine, for example `isiscloudwin1`.
3. The `Username` field is typically automatically populated. For ISIS users it will be their username in the `CLRC` domain: `CLRC\<username>`.
4. Upon clicking `Connect` you will be prompted to enter the password typically associated with your username.
5. If you have successfully established a remote connection to the virtual machine, a windows desktop will be opened in a new window.

## Install git

1. The easiest way to install `git` is via `chocolatey`. To use `chocolatey`, it must first be installed itself.
2. Open `powershell` in administrator mode. Run `Set-ExecutionPolicy Bypass -Scope Process -Force`.
3. Run
   ```sh
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`
   ```

4. Confirm chocolatey has been downloaded and installed correctly using `choco --version`.
5. Download and install `git` using `choco install -y git.install`.
6. Close and reopen `powershell`.
7. Confirm git has been downloaded and installed correctly using `git --version`.

## Install Docker

1. Open `powershell` in administrator mode. Run `Set-ExecutionPolicy Bypass -Scope Process -Force`.
1. Run `Install-Module -Name DockerMsftProvider -Repository PSGallery -Force`. This is the provider that will enable access to the docker online package repository.
3. Check the `DockerMsftProvider` module has been installed by checking the output of `Get-PackageProvider -ListAvailable`.
4. Run `Install-Package -Name docker -ProviderName DockerMsftProvider` to install `docker`.
5. Check that the docker package has been installed using `Get-Package -Name Docker -ProviderName DockerMsftProvider`.
6. Restart the virtual machine using `Restart-Computer -Force`, then remote back in to the machine.
7. Reopen `powershell` in administrator mode. Start the `docker` service using `Start-service docker`
8. Check docker is running correctly using `Docker version` (note the lack of `--`). If docker is available, the following output or similar is to be expected:
```sh
Client: Mirantis Container Runtime
 Version:           20.10.9
 API version:       1.41
 Go version:        go1.16.12m2
 Git commit:        591094d
 Built:             12/21/2021 21:34:30
 OS/Arch:           windows/amd64
 Context:           default
 Experimental:      true

Server: Mirantis Container Runtime
 Engine:
  Version:          20.10.9
  API version:      1.41 (minimum version 1.24)
  Go version:       go1.16.12m2
  Git commit:       9b96ce992b
  Built:            12/21/2021 21:33:06
  OS/Arch:          windows/amd64
  Experimental:     false
```

## Set up Node on Jenkins

1. Using the `jenkins` web UI (https://builds.mantidproject.org/), navigate to `Manage Jenkins` then `Manage nodes and clouds` under `System Configuration`.
2. On the side bar, select `New Node`. Enter the Node name using the naming convention `<virtual machine name>-<n>`, `<n>` being the node index base 1 to be hosted on that VM.
3. Select the `Copy Existing Node` radio button. Type `isiscloudwin1-1` into the emergent text box and click `Create`.
4. The node configuration will appear, in the `Labels` input box append `-test` to `win-64-cloud` then click `Save`.
5. Take note of the jenkins secret, an encryption key stated after `-secret` in the code box entitled `Run from agent command line`. This key will be needed to enable access to Jenkins.

## Build Image (Only required upon the setting up of the first windows node on a VM, or following a change to the image).

1. Clone the `mantidproject/dockerfiles` repository (https://github.com/mantidproject/dockerfiles).
2. Open `powershell` in administrator mode.
3. `cd` into `<dockerfiles root path>\ Windows\jenkins-node`
4. Run `docker build -t <docker image name> -f Win.Dockerfile .`
5. Confirm that the image has successfully been built by viewing the output from `docker images`

## Create container
1. Open `powershell` in administrator mode.
2. `cd` into `<dockerfiles root path>\Windows\jenkins-node`
3. Create a container from the image using the command:
   ```sh
   docker run -d --name <cloud node name> --storage-opt "size=250GB" <docker image name> -Url https://builds.mantidproject.org -Secret <jenkins secret> -WorkDir C:/jenkins_workdir -Name <cloud node name>
   ```

4. Confirm that the container has been created and is listed as running using `docker container ps -a`.
5. To SSH into the container to access the command line, `docker exec -it <cloud node name> cmd` can be used.

## Testing the new node

1. Log in to the `Jenkins` web UI (https://builds.mantidproject.org/), navigate to `Manage Jenkins`, then `Manage nodes and clouds` under `System Configuration`.
2. On the `Manage nodes and clouds` page of Jenkins, select the new node from the table.
3. Ensure the node is online. If `Bring this node back online` is available on the right of screen, select it.
4. If the cloud node is connected to Jenkins, `Agent is connected` will be stated below the agent name. 
5. In a new tab, navigate to the Jenkins home page, from the pipeline table select `testing-new-windows-builder`. From the menu on the left-hand side of the page, select `Build Now`.
6. Switch back to the previous tab, refreshing if necessary. Observe that the new node is running the `testing-new-windows-builder` job.
7. If the node is not running the job, there may be other nodes with the `win-64-cloud-test` label. Either bring these other nodes offline (ensuring they are not undertaking any jobs) or raise the `Preference Score` of the desired node via `Configure` and rerun the job.
8. From the menu on the left-hand side of the page, select `Script Console`, ensure that the job status is successful upon conclusion, and that all the tests pass (note that the job status cannot solely be relied upon).
9. Finally, change the label on the node back to `win-64-cloud` via `Configure` (and reset the preference score if applicable). This will enable the node to take part in the CI/CD pipeline.
