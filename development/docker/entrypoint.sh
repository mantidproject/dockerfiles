#!/bin/bash

# Handles setting up the target user (abc) and redirecting the command to be
# executed by them.
# This is all in aid of ensuring that permissions of filesystem mapped volumes
# function correctly and that the root user is not used within the container.

set -x

TARGET_USERNAME="abc"

# Execute entrypoint rules
for rule in /etc/entrypoint.d/*.sh;
do
  env \
    TARGET_USERNAME=$TARGET_USERNAME \
    $rule
done

# Run the supplied command as the target user
CMD=${@:-"bash"}
# This form of runuser is used as it only sets the environment variables
# required to change the user, preserving all others that are set (see man
# runuser).
runuser -u ${TARGET_USERNAME} -- ${CMD}
