# Jenkins macOS nodes for Mantid

This describes how to deploy a macOS build node. Such a node is able to perform any of the macOS jobs.

## Prerequisites

- Access to the Keeper password manager and the `ISIS Jenkins Nodes` file.
- Access to the [`mantidproject/ansible-linode`](https://github.com/mantidproject/ansible-linode) and [`dockerfiles`](https://github.com/mantidproject/dockerfiles) repositories.
- If the machine was already setup, you will need your SSH key adding to the list so you can connect remotely.


## Manual Setup

There are few steps that need to be manually taken on a brand new machine before ansible can take over.

- Login to the provided administrator account.
- Set up a `mantidbuilder` user on the new machine:

    - Open the `System Preferences -> Users & Groups` menu.
    - Press the `+` button below the list of users and add a new administrator account. Use `mantidbuilder` for both the name fields and provide a strong password.

- Enable remote access:

    - Open `System Preferences -> Sharing`. May also be `System Preferences -> General -> Sharing`.
    - Enable `Remote Login` for all users and allow full disk access.
    - Make a note of the `ssh` login instructions, especially the hostname after the `@`.
    - Store the chosen password and the hostname in the `ISIS Jenkins Nodes` file in Keeper.
    - Enable `Remote Management` for all users.
    - Click the `i` button and enable `VNC viewers may control screen with password`.

- Set security settings to allow for builds and consistent access:

    - Open `System Preferences -> Security & Privacy`.
    - In `General`, untick the `Require password [...] after sleep or screensaver begins` checkbox.
    - In `FileVault` press the button to `Turn Off FileVault`.
        - FileVault encrypts the contents of the disk until the first login. This means that the `ssh` service is not started until someone logs in on the physical machine, which makes the machine a pain to access after reboot.

- Install XCode Command Line Tools:

    - Launch a terminal.
    - Run `xcode-select --install`.
    - Wait for the popup to appear and click `Install`.


- Back on the machine you will be doing the deployment on, you will need to add your SSH key to the new mac:

    - `ssh-copy-id mantidbuilder@<HOST>`

## Jenkins Controller Node Creation

- Provision a new node in [Jenkins](https://builds.mantidproject.org/computer) with the following changes:
  - Set *Remote root directory* to `/jenkins_workdir`
  - Set environment variables:
    - `BUILD_THREADS` => set based on system, e.g. number of cores
    - `MANTID_DATA_STORE` => `/mantid_data`
- Once created make a note of the node's name and secret (the long string of letters and numbers)

## Deploying to the Agent

**We're calling nodes _agents_ from here on out. There's some nuance, but they're mostly interchangeable terms.**

The ansible scripts will set up the machine and connect it to the Jenkins controller ready for running builds and other jobs.

### Getting the Right Environment

1. If you already have the `ansible-linode` repo and associated conda environment, activate it and skip to step 4.
2. Clone the [`mantidproject/ansible-linode`](https://github.com/mantidproject/ansible-linode) repo.
3. Navigate to the base of the cloned repo and run:

    - `mamba create --prefix ./condaenv ansible`
    - `mamba activate ./condaenv`
    - Note: You can activate the environment from anywhere by providing the full path to the `condaenv` directory.

4. Clone the [`dockerfiles`](https://github.com/mantidproject/dockerfiles) repo and navigate to `macOS/jenkins-node/ansible`.
5. Install or Update the required collections from Ansible Galaxy by running:
    - `ansible-galaxy install -r requirements.yml --force`
6. Time to use that secret you made a note of. Create an `inventory.txt` file with the details of the machines to deploy to (one per line):

    ```ini
    [all]
    <IP_ADDRESS_OR_HOSTNAME_1> agent_name=<NAME_OF_AGENT_ON_JENKINS_1> agent_secret=<SECRET_DISPLAYED_ON_CONNECTION_SCREEN_1>
    <IP_ADDRESS_OR_HOSTNAME_2> agent_name=<NAME_OF_AGENT_ON_JENKINS_2> agent_secret=<SECRET_DISPLAYED_ON_CONNECTION_SCREEN_2>
    ```

    If you've forgotten the secret, it can be found under `Environment Variables` in the `System Information` section of the agent.

### Running the Script to Deploy the Agent

1. Add your SSH key to the host by running the following in a terminal:

    ```sh
    ssh-copy-id mantidbuilder@<HOSTNAME>
    ```

2. Run the playbook to deploy to all the machines defined in your `inventory.txt` file:

    ```sh
    ansible-playbook -i inventory.txt jenkins-agent.yml -u mantidbuilder -K
    ```

3. When prompted, enter the agent's password that you made earlier. If you weren't the one who made the password, it should be in the `ISIS Jenkins Nodes` file on Keeper.
4. Wait for the play to complete and visit `builds.mantidproject.org/computer/NAME_OF_AGENT_ON_JENKINS`. The agent should be connected within five minutes.

    - Note: The agent is kept connected to the controller by a crontab entry that runs on every 5th minute. This means that on first setup the agent may not connect until a minute divisible by five has passed. 

## Cleaning nodes

- Before cleaning any nodes mark them temporarily offline on Jenkins and ensure no jobs are running on them before cleaning.

- Update the `inventory.txt` file [as above](#getting-the-right-environment), including only the nodes you intend to clean.

- If you haven't done it already, add your SSH key to the host.

    ```sh
    ssh-copy-id mantidbuilder@<HOSTNAME>
    ```

- The tasks in the cleaning playbook make use of tags to determine what is cleaned:

  - `pr`: Pull Requests.
  - `nightly`: Nightly deployments for main and release next.
  - `package`: Build Packages from Branch.
  - `docs`: Docs build and publish.
  - `core`: Core Team test pipeline builds.

- Run the following with the desired tags (using a comma-separated list):

    ```sh
    ansible-playbook -i inventory.txt clean-jenkins-agents.yml -u mantidbuilder -K -t pr,nightly,package,docs,core
    ```

- Set the nodes you shut down back online.

## Troubleshooting

- You may need to log in manually or by using VNC at least once to allow the ansible script to run. This can be due to FireVault blocking SSH connections until the machine is unlocked.
    - To make use of VNC from a mac: Open finder and press `Cmd+K`, then enter `vnc://<HOSTNAME>`. Use the `mantidbuilder` login for the machine.
