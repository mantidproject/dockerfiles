#!/bin/bash

function usage {
  echo "Dockerized Jenkins agent deploy script"
  echo "Usage: $0 [agent name] [agent secret] [jenkins url] [docker image tag] [ccache size]"
  exit
}

if [[ $# -ne 5 ]]
then
  usage
fi

NODE_NAME=$1
JENKINS_SECRET=$2
JENKINS_URL=$3
IMAGE_TAG=$4
CCACHE_SIZE=$5

echo "=== Parameters"
echo "    name: ${NODE_NAME}"
echo "    secret: ${JENKINS_SECRET}"
echo "    url: ${JENKINS_URL}"
echo "    tag: ${IMAGE_TAG}"

# Ensure we have the latest version
echo "=== Pulling latest image"
docker pull mantidproject/jenkins-node:${IMAGE_TAG}

# Search for any existing container with the given name
EXISTING_CONTAINER_ID=`docker container ls --all --format="{{.ID}}" --filter name=${NODE_NAME}`

# Stop and remove the container if there is one
if [[ -n ${EXISTING_CONTAINER_ID} ]]
then
  echo "=== Stopping and removing existing container with ID ${EXISTING_CONTAINER_ID}"
  docker stop ${EXISTING_CONTAINER_ID}
  docker container rm ${EXISTING_CONTAINER_ID}
fi

# Start a new container
echo "=== Starting new container"
NEW_CONTAINER_ID=`docker run \
  --detach \
  --init \
  --name ${NODE_NAME} \
  --restart=always \
  --net=host \
  --shm-size=512m \
  --volume ${NODE_NAME}:/jenkins_workdir \
  --volume ${NODE_NAME}_ccache:/ccache \
  --volume ${NODE_NAME}_external_data:/mantid_data \
  --env JENKINS_SECRET=${JENKINS_SECRET} \
  --env JENKINS_AGENT_NAME=${NODE_NAME} \
  --env JENKINS_URL="${JENKINS_URL}" \
  mantidproject/jenkins-node:${IMAGE_TAG}`

echo "Started: ${NEW_CONTAINER_ID}"

# Set CCache max size
docker exec ${NEW_CONTAINER_ID} ccache --max-size ${CCACHE_SIZE}
