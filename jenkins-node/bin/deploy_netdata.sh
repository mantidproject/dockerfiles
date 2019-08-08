#!/bin/bash

# Ensure we have the latest version
echo '=== Pulling latest image'
docker pull netdata/netdata

# Search for any existing container with the given name
EXISTING_CONTAINER_ID=`docker container ls --all --format="{{.ID}}" --filter name='netdata'`

# Stop and remove the container if there is one
if [[ -n ${EXISTING_CONTAINER_ID} ]]
then
  echo "=== Stopping and removing existing container with ID $EXISTING_CONTAINER_ID"
  docker stop "$EXISTING_CONTAINER_ID"
  docker container rm "$EXISTING_CONTAINER_ID"
fi

# Start a new container
echo '=== Starting new container'
set -x
docker run \
  --name=netdata \
  --detach \
  --restart=always \
  --publish 19999:19999 \
  --volume /etc/passwd:/host/etc/passwd:ro \
  --volume /etc/group:/host/etc/group:ro \
  --volume /proc:/host/proc:ro \
  --volume /sys:/host/sys:ro \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata
