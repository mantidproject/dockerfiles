#!/bin/bash

# Note this relies on the fact a running Jenkins node will have a fairly up-to-date cache.

function usage {
  echo 'Nginx Cache Deployment Script'
  echo "Usage: $0 [agent name]"
  exit
}

if [[ $# -ne 1 ]]
then
  usage
fi

IMAGE='nginx:stable'
NODE_NAME='nginx-external-data'
AGENT_NAME=$1
VOLUME_NAME="$1_external_data"

docker pull "$IMAGE"

# Search for any existing container with the given name
EXISTING_CONTAINER_ID=`docker container ls --all --format="{{.ID}}" --filter name="$NODE_NAME"`

# Stop and remove the container if there is one
if [[ -n "$EXISTING_CONTAINER_ID" ]]
then
  echo "=== Stopping and removing existing container with ID $EXISTING_CONTAINER_ID"
  docker stop "$EXISTING_CONTAINER_ID"
  docker container rm "$EXISTING_CONTAINER_ID"
fi

# Start a new container
echo '=== Starting new container'
NEW_CONTAINER_ID=`docker run \
  --detach \
  --name "$NODE_NAME" \
  --restart=always \
  --net=host \
  --env PUID=$(id -u) \
  --env PGID=$(id -g) \
  --env HOST_DOCKER_GID=$(id -g docker) \
  --volume "$VOLUME_NAME:/usr/share/nginx/html/externaldata/:ro" \
  "$IMAGE"`

echo "Started: $NEW_CONTAINER_ID"
