# Cloud Windows Jenkins Node Setup

This document provides instructions for setting up a Cloud Windows Jenkins node on a cloud hosted virtual machine running the `Windows Server 2019` OS.

## Permissions

Before setting up a cloud Windows Jenkins node, you will need to have the following permissions. If you do not have any of these permissions, please contact a member of the RAL Devops team.

- Admin access to both the cloud Windows virtual machine to host the node.
- Admin access to Jenkins.
- Read access to the mantidproject/dockerfiles repository.

## Connect to the windows cloud virtual machine

1. Press `Windows key` + `R`. Type in `MSTSC` and hit `Enter` to open `Remote Desktop Connection`.
2. In the `Computer` field type the name of the cloud virtual machine, for example ` isiscloudwin1`.
3. The `Username` field is typically automatically populated. For ISIS users it will be their username in the CLRC domain: `CLRC\<local username>`.
4. Upon clicking `Connect` you will be prompted to enter the password typically associated with your domain username.
5. If you have successfully established a remote connection to the virtual machine, a windows desktop will be opened in a new window.

## Install git

1. The easiest way to install `git` is via `chocolatey`. To use `chocolately`, it must first be installed itself.
2. Open `powershell` in administrator mode. Run `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`, entering `A` when prompted. YOU MUST REMEMBER TO CHANGE THIS BACK VIA STEP 5.
3. Run ` Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`.
4. Confirm chocolatey has been downloaded and installed correctly using `choco --version`.
5. Reset the execution policy using `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`.
6. Download and install `git` using `choco install git.install`.
7. Confirm git has been downloaded and installed correctly using `git --version`.

## Install Docker

1. Open `powershell` in administrator mode. Run `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`, entering `A` when prompted. YOU MUST REMEMBER TO CHANGE THIS BACK VIA STEP 8.
1. Run `Install-Module -Name DockerMsftProvider -Repository PSGallery -Force`.
3. Check the ` DockerMsftProvider` module has been installed by checking the output of ` Get-PackageProvider -ListAvailable`.
4. Run `Install-Package -Name docker -ProviderName DockerMsftProvider` to install `docker`.
5. Check that the docker package has been installed using ` Get-Package -Name Docker -ProviderName DockerMsftProvider`.
6. Add the `docker` root path (`C:\Program Files\Docker` by default) to the system path variable.
7. Restart the virtual machine using ` Restart-Computer -Force`
8. After reconnecting, reset the execution policy using `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`.
9. Open `powershell` in administrator mode. Set docker as a service using ` &'<docker path>\dockerd.exe' --run-service`
10. Start the new `docker` service using `Start-service docker`
11. Check docker is running correctly using `Docker version` (note the lack of `--`). If docker is available, the following output or similar is to be expected:
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

1. Using the `jenkins` web UI (https://builds.mantidproject.org/) navigate to `Manage Jenkins` then `Manage nodes and clouds` under `System Configuration`.
2. On the side bar, select `New Node`. Enter the Node name which should be the same as the virtual machine name.
3. Select the `Copy Existing Node` radio button. Type `isiscloudwin1` into the emergent text box and click `Create` then `Save`.
4. Take note of the jenkins secret, an encryption key stated after `-secret` in the code box entitled ‘Run from agent command line`. This key will be needed to enable access to Jenkins.

## Build Image and Create container

1. Clone the mantidproject/dockerfiles repository. 
2. Open `powershell` in administrator mode.
3. `cd` into `<dockerfiles root path>\ Windows\jenkins-node`
4. Run `docker build -t <virtual machine name> -f Win.Dockerfile .`
5. Confirm that the image has successfully been built using `docker images`
6. Create a container from the image using the command:
   `start-Job -ScriptBlock {docker run --name <virtual machine name> --storage-opt "size=250GB" isiscloudwin1 -Url https://builds.mantidproject.org -Secret <jenkins secret> -WorkDir C:/jenkins_workdir -Name <virtual machine name>}`
   This command runs in the background, so don’t expect output.
7. Confirm that the container has been created and is listed as running using `docker container ps -a`.
8. In order to ssh into the container to access the command line, you can use `docker exec -it isiscloudwin1 cmd`.

## Testing the new node

1. Using the `Jenkins` web UI (https://builds.mantidproject.org/) navigate to `Manage Jenkins` then `Manage nodes and clouds` under `System Configuration`.
2. On the ` Manage nodes and clouds` page of Jenkins, select the new node from the table.
3. Ensure the node is online – if `Bring this node back online` is available on the right of screen, select it.
4. If the cloud node is connected to Jenkins, `Agent is connected` will be stated below the agent name. 
5. From the menu on the left-hand side of the page, select `Configure`. Scroll down, set the preference score to `1000` and click save - this will ensure this node is used to run the test job.
6. In a new tab, navigate to the Jenkins home page, from the pipeline table select `testing-new-windows-builder`. From the menu on the left-hand side of the page, select Build Now.
7. Switch back to the previous tab, refreshing if necessary. Observe that the new node is running the `testing-new-windows-builder` job.
8. From the menu on the left-hand side of the page, select `Script Console`, ensure that the job status is successful, and that all the tests pass (note that the job status cannot solely be relied upon. 
