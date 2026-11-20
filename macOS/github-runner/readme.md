# Native GitHub self-hosted runner for macOS

This describes how to register a macOS machine as a GitHub self-hosted runner in the `mantidproject/mantid` repository.

The macOS runner is installed **natively** on the machine, following the same physical-machine model already used for the [macOS Jenkins node](../jenkins-node/README.md), with the GitHub Actions runner application registered and run as a `launchd` service instead of a Docker container.

## Prerequisites

- A [fine-grained GitHub token](https://github.com/settings/personal-access-tokens/new) with:
  - resource owner: `mantidproject`
  - repository access: Only select repositories (select `mantidproject/mantid`)
  - permissions: Administration (Read and write)

  See [here](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository--fine-grained-access-tokens) for reference and instructions for generating a registration token.

## Manual machine setup

If the Mac has not been used as a build node before, do the following first (identical to the Jenkins node setup, see [macOS/jenkins-node/README.md](../jenkins-node/README.md#manual-setup) for full detail):

- Log in to the provided administrator account and create a `mantidbuilder` user (`System Settings -> Users & Groups`).
- Enable `Remote Login` and `Remote Management` under `System Settings -> General -> Sharing` for all users, and note the hostname used after the `@` in the SSH login.
- Under `System Settings -> Privacy & Security`:
  - Untick "Require password after sleep or screensaver begins".
  - Turn off FileVault (otherwise the machine won't accept SSH connections until someone logs in locally after a reboot).
- Install the Xcode Command Line Tools:

  ```sh
  xcode-select --install
  ```

- Add your SSH key to the machine:

  ```sh
  ssh-copy-id mantidbuilder@<HOST>
  ```

## Registering the runner

The `ansible/` directory automates the same steps: it generates a registration token via the GitHub API and configures/installs the runner as a service.

1. Clone the [`dockerfiles`](https://github.com/mantidproject/dockerfiles) repo and navigate to `macOS/github-runner/ansible`.

2. Create and activate a conda environment for Ansible (or reuse the one from `macOS/jenkins-node`):

   ```sh
   mamba create --prefix ./condaenv ansible
   mamba activate ./condaenv
   ```

3. Install the required collections:

   ```sh
   ansible-galaxy install -r requirements.yml --force
   ```

4. Create an `inventory.txt` file with one line per machine:

   ```ini
   [all]
   <IP_ADDRESS_OR_HOSTNAME_1> runner_name=<NAME_OF_RUNNER_1>
   <IP_ADDRESS_OR_HOSTNAME_2> runner_name=<NAME_OF_RUNNER_2>
   ```

5. Add your SSH key to each host if you haven't already:

   ```sh
   ssh-copy-id mantidbuilder@<HOSTNAME>
   ```

6. Export the fine-grained PAT from the prerequisites and run the playbook:

   ```sh
   export GITHUB_TOKEN=<github_token>
   ansible-playbook -i inventory.txt github-runner.yml -u mantidbuilder -K
   ```

   `-K` prompts for the `mantidbuilder` account password, needed to install the `launchd` service.

7. Confirm the runner(s) appear at `https://github.com/mantidproject/mantid/settings/actions/runners` within a minute or two.

   `runner_version` in `github-runner.yml` defaults to `latest`, which is resolved to the current release via the GitHub API at deploy time. Pin it to a specific version (e.g. `2.319.1`) if you need reproducible deploys.

## Removing a runner

1. Mark the runner offline/idle on GitHub first (don't remove while a job is running).
2. On the machine:

   ```sh
   cd ~/actions-runner
   ./svc.sh stop
   ./svc.sh uninstall
   ./config.sh remove --token <removal_token>
   ```

   The removal token is shown on the runner's page under `Settings -> Actions -> Runners -> <runner> -> Remove`, or can be generated via the [remove-token API endpoint](https://docs.github.com/en/rest/actions/self-hosted-runners#create-a-remove-token-for-a-repository).

## Troubleshooting

- If `ansible-playbook` can't connect, you may need to log in locally or via VNC once first (FileVault can block SSH until the machine is unlocked). From another Mac: Finder -> `Cmd+K` -> `vnc://<HOSTNAME>`, using the `mantidbuilder` login.
- If macOS blocks the downloaded runner binaries with a Gatekeeper/quarantine warning, clear the quarantine attribute before running `config.sh`:

  ```sh
  xattr -d com.apple.quarantine ~/actions-runner/bin/*
  ```

- `./svc.sh status` and `~/actions-runner/_diag/` logs are the first places to check if the runner shows as offline.
