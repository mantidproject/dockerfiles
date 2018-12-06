#!/bin/bash

# ARTIFACT_DIR must be in the Docker build context (simplest solution is the
# same directory as the Dockerfiles)
ARTIFACT_DIR="artifacts"
mkdir -p "${ARTIFACT_DIR}"

# Load build tools
. build_nightly.sh

# Login to Docker Hub
docker --config=${WORKSPACE}/.docker login --username=${DOCKER_HUB_USERNAME} --password=${DOCKER_HUB_PASSWORD}

function build_and_push {
  DOCKERFILE=$1
  TAG=$2
  PACKAGE_FILENAME_PATTERN=$3

  # Look for a package in copied artifacts
  PACKAGE_FILENAME=`ls ${ARTIFACT_DIR}/${PACKAGE_FILENAME_PATTERN}`

  # If package exists in copied artifacts
  if [ -n "${PACKAGE_FILENAME}" ] && [ -f "${PACKAGE_FILENAME}" ]; then
    echo "Found package \"${PACKAGE_FILENAME}\" for tag \"${TAG}\""
    # Build Docker image
    build_image ${DOCKERFILE} ${TAG} "${PACKAGE_FILENAME}"
    # Push to Docker Hub
    docker --config=${WORKSPACE}/.docker push mantidproject/mantid:${TAG}
  fi
}

# Build nightly images
build_and_push Dockerfile_CentOS7_Nightly nightly "*el7*.rpm"
build_and_push Dockerfile_CentOS7_Nightly nightly_centos7 "*el7*.rpm"
build_and_push Dockerfile_Ubuntu16.04_Nightly nightly_ubuntu16.04 "*xenial*.deb"

# Logout of Docker Hub
docker --config=${WORKSPACE}/.docker logout

# Remove artifacts
rm -r ${ARTIFACT_DIR}
