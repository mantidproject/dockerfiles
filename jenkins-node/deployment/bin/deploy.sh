#!/bin/bash

function usage {
  echo 'Dockerized Jenkins agent deploy script'
  echo "Usage: $0 [agent name] [agent secret] [jenkins url]"
  exit
}

if [[ $# -ne 3 ]]
then
  usage
fi

NODE_NAME=$1
JENKINS_SECRET=$2
JENKINS_URL=$3

echo '=== Parameters'
echo "    name: $NODE_NAME"
echo "    secret: $JENKINS_SECRET"
echo "    url: $JENKINS_URL"


# Search for any existing container with the given name
EXISTING_CONTAINER_ID=`docker container ls --all --format="{{.ID}}" --filter name="$NODE_NAME"`

# Stop and remove the container if there is one
if [[ -n ${EXISTING_CONTAINER_ID} ]]
then
  echo "=== Stopping and removing existing container with ID $EXISTING_CONTAINER_ID"
  docker stop "$EXISTING_CONTAINER_ID"
  docker container rm "$EXISTING_CONTAINER_ID"
fi

# Start a new container
# Assume it has been built
echo '=== Starting new container'
NEW_CONTAINER_ID=`docker run \
  --detach \
  --init \
  --name "$NODE_NAME" \
  --restart=always \
  --net=host \
  --shm-size=512m \
  --volume "${NODE_NAME}:/jenkins_workdir" \
  --env JENKINS_SECRET="$JENKINS_SECRET" \
  --env JENKINS_AGENT_NAME="$NODE_NAME" \
  --env JENKINS_URL="$JENKINS_URL" \
  "mantidproject/jenkins-deployment-node"`

echo "Started: $NEW_CONTAINER_ID"
