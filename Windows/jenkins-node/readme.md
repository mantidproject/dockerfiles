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
2. Install `docker` using the following command. This will restart the host VM; you will need to remote back into the machine.
```sh
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
.\install-docker-ce.ps1
```

3. Reopen `powershell` in administrator mode. Check docker is running correctly using `Docker version` (note the lack of `--`). If docker is available, the following output or similar is to be expected:
```sh
Client: Mirantis Container Runtime
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.20.10
 Git commit:        afdd53b
 Built:             Thu Oct 26 09:08:44 2023
 OS/Arch:           windows/amd64
 Context:           default
 Experimental:      true

Server: Mirantis Container Runtime
 Engine:
  Version:          24.0.7
  API version:      1.43 (minimum version 1.24)
  Go version:       go1.20.10
  Git commit:       311b9ff
  Built:            Thu Oct 26 09:07:37 2023
  OS/Arch:          windows/amd64
  Experimental:     false
```

## Set up Node on Jenkins

1. Using the `jenkins` web UI (https://builds.mantidproject.org/), navigate to `Manage Jenkins` then `Manage nodes and clouds` under `System Configuration`.
2. On the side bar, select `New Node`. Enter the Node name using the naming convention `<virtual machine name>-<n>`, `<n>` being the node index base 1 to be hosted on that VM.
3. Select the `Copy Existing Node` radio button. Type `isiscloudwin1-1` into the emergent text box and click `Create`.
4. The node configuration will appear, in the `Labels` input box append `-test` to `win-64-cloud` then click `Save`.
5. Take note of the jenkins secret, an encryption key stated after `-secret` in the code box entitled `Run from agent command line`. This key will be needed to enable access to Jenkins.

## Pull Image (Only required upon the setting up of the first windows node on a VM, or following a change to the image).

1. Open `powershell` in administrator mode.
2. Run `docker pull ghcr.io/mantidproject/isiscloudwin:latest`
3. Confirm that the image has successfully been pulled by viewing the output from `docker images`

## Create container
1. Open `powershell` in administrator mode.
2. Create a container from the image using the command:
   ```sh
   docker run -d --name <cloud node name> --storage-opt "size=250GB" ghcr.io/mantidproject/isiscloudwin:latest -Url https://builds.mantidproject.org -Secret <jenkins secret> -WorkDir C:/jenkins_workdir -Name <cloud node name>
   ```

3. Confirm that the container has been created and is listed as running using `docker container ps -a`.
4. To SSH into the container to access the command line, `docker exec -it <cloud node name> cmd` can be used.

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

# Cloud Windows Jenkins Node Troubleshooting

## First response to failure

If a cloud windows Jenkins node has run into issues, the first port of call should be to stop, remove, and rerun the docker container:

### Bring the node offline

1. Log in to the `Jenkins` web UI (https://builds.mantidproject.org/), navigate to `Manage Jenkins`, then `Manage nodes and clouds` under `System Configuration`.
2. On the `Manage nodes and clouds` page of Jenkins, select the node in question from the table.
3. Ensure the node is offline if it isn't already: If `Mark this node temporarily offline` is available on the right of screen, select it.

### Restart the container and bring back online

1. On your local machine, [connect to the VM hosting the node in question using the instructions outlined](##-connect-to-the-windows-cloud-virtual-machine).
2. Open `powershell` in administrator mode.
3. Stop the container: `docker stop <cloud node name>`.
4. Remove the container: `docker rm <cloud node name>`.
5. Run the container: 
   ```sh
   docker run -d --name <cloud node name> --storage-opt "size=250GB" --restart on-failure:3 <docker image name> -Url https://builds.mantidproject.org -Secret <jenkins secret> -WorkDir C:/jenkins_workdir -Name <cloud node name>
   ```

6. Confirm that the container has been created and is listed as running using `docker container ps -a`.
7. On the `Jenkins` web UI, refresh the page and ensure that `Agent is connected` is displayed. Click `Bring this node back online`.

## Upon continued failure

If a cloud windows Jenkins node continues to fail having been rerun, the issue may be with the VM which is hosting it. To restart this VM:

1. Bring the node offline as detailed in the above [section](###-bring-the-node-offline).
2. On your local machine, [connect to the VM hosting the node in question](##-connect-to-the-windows-cloud-virtual-machine).
3. Using the start menu, simply click the power symbol and select `Restart`.
4. After a short period, [restart the container and bring it back online](###-restart-the-container-and-bring-back-online)

## Upon failure to restart

If the virtual machine fails to come back online after restart, or if issues persist after restart, the VM should be restarted via the `Virtual Machine Manager Console` (VMMC):

### Install the VMMC

1. Access `\\FITCLOUDVMMSB2\VMM2016ConsoleInstall$`. If you cannot access this file location, you will have to be granted permissions: please contact a member of the RAL Mantid Devops team.
2. In the subdirectory `BaseInstallVMM2016` run `setup.exe`. Select `Install`, then `Add Features`, ticking the `VMM Console` checkbox. Follow the install through selecting all defaults as you progress.
3. After a successful install, navigate to the second subdirectory `LatestConsoleUR` and run `UR7_kb4496921_AdminConsole_amd64.smp`. This will install the latest update.

### Using the VMMC
1. Start the VMMC from the start menu.
2. Enter `fitcloudbase.isis.cclrc.ac.uk:8100` as the `Server Name` and select the `Specify credentials` radio button and log in with your FED ID/password (no need to specify a domain). If unable to login please contact a member of the RAL Mantid Devops team as you may need to be granted permissions.
3. Upon successful login, the console will open. On the `VMs and Services pane` on the left hand side, under the `Clouds` collapsible header, you will see three clouds: `F5GALAXY Cloud`, `F6GALAXY Cloud` and `F7GALAXY Cloud`.
4. Our VMs are hosted on `F6GALAXY Cloud` and `F7GALAXY Cloud`. As you click on the clouds, the VMs hosted on that cloud will appear in the main central pane. Find and select the VM in question.
5. Having selected the VM, on the task bar click `reset`. You will be promoted with a warning - click `OK` if you want to proceed with a reset of the VM.
6. After a short period following reset of the VM, [restart the container and bring it back online](###-restart-the-container-and-bring-back-online).
