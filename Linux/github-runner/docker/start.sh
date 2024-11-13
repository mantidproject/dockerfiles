#!/bin/bash

# Must provide the github organisation, repo and a repository level fine-grained token with the following perimssion set:
#  - "Administration" repository permissions (write)

ORGANIZATION=$ORGANIZATION
REPOSITORY=$REPOSITORY
GITHUB_TOKEN=$GITHUB_TOKEN

#REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)
#REG_TOKEN=$(curl -sX POST -H "Authorization: Bearer ${GITHUB_TOKEN}"  -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/${ORGANIZATION}/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)
REG_TOKEN=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${ORGANIZATION}/${REPOSITORY}/actions/runners/registration-token \
  | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${ORGANIZATION}/${REPOSITORY} --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
