#!/bin/bash

# Must provide the github organisation, repo, runner name, and a runner registration token
ORGANIZATION=$ORGANIZATION
REPOSITORY=$REPOSITORY
RUNNER_NAME=$RUNNER_NAME
REG_TOKEN=$REG_TOKEN

cd /home/docker/actions-runner

#
# ./config.sh --help
#
# Config Options:
#  --unattended           Disable interactive prompts for missing arguments. Defaults will be used for missing options
#  --url string           Repository to add the runner to. Required if unattended
#  --token string         Registration token. Required if unattended
#  --name string          Name of the runner to configure (default 2c450a2cef7d)
#  --runnergroup string   Name of the runner group to add this runner to (defaults to the default runner group)
#  --labels string        Custom labels that will be added to the runner. This option is mandatory if --no-default-labels is used.
#  --no-default-labels    Disables adding the default labels: 'self-hosted,Linux,X64'
#  --local                Removes the runner config files from your local machine. Used as an option to the remove command
#  --work string          Relative runner work directory (default _work)
#  --replace              Replace any existing runner with the same name (default false)
#  --pat                  GitHub personal access token with repo scope. Used for checking network connectivity when executing `./run.sh --check`
#  --disableupdate        Disable self-hosted runner automatic update to the latest released version`
#  --ephemeral            Configure the runner to only take one job and then let the service un-configure the runner after the job finishes (default false)
#

./config.sh \
  --unattended \
  --url https://github.com/${ORGANIZATION}/${REPOSITORY} \
  --token ${REG_TOKEN} \
  --name ${RUNNER_NAME} \
  --replace \
  --labels ${RUNNER_NAME}

unset REG_TOKEN

./run.sh & wait $!
