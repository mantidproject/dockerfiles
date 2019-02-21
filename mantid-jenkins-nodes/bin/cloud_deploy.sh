#!/bin/bash

# A version of deploy.sh that always pulls an up to date script from the Git repo
# No signing is done so obviously don't use this version if you care about security

SCRIPT_URL="https://raw.githubusercontent.com/mantidproject/dockerfiles/master/mantid-jenkins-nodes/bin/deploy.sh"
curl --silent --output - "$SCRIPT_URL" | bash -s -- $@
