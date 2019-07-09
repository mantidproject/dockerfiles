#!/bin/bash

# ARTIFACT_DIR must be in the Docker build context (simplest solution is the
# same directory as the Dockerfiles)
ARTIFACT_DIR="artifacts"
mkdir -p "${ARTIFACT_DIR}"

# Load build tools
. build_helpers.sh

# Login to Docker Hub
docker --config=${WORKSPACE}/.docker login --username=${DOCKER_HUB_USERNAME} --password=${DOCKER_HUB_PASSWORD}

function build_and_push {
  DOCKERFILE=$1
  TAG=$2
  PATH_ADDITIONS=$3
  PACKAGE_FILENAME_PATTERN=$4

  # Look for a package in copied artifacts
  PACKAGE_FILENAME=`ls ${ARTIFACT_DIR}/${PACKAGE_FILENAME_PATTERN}`

  # If package exists in copied artifacts
  if [ -n "${PACKAGE_FILENAME}" ] && [ -f "${PACKAGE_FILENAME}" ]; then
    echo "Found package \"${PACKAGE_FILENAME}\" for tag \"${TAG}\""
    # Build Docker image
    build_image ${DOCKERFILE} ${TAG} "${PACKAGE_FILENAME}" "${PATH_ADDITIONS}"
    # Push to Docker Hub
    docker --config=${WORKSPACE}/.docker push mantidproject/mantid:${TAG}
  fi
}

NIGHTLY_PYTHON2_PATH="/opt/mantidnightly/bin/"
NIGHTLY_PYTHON3_PATH="/opt/mantidnightly-python3/bin/"

# Build nightly images
build_and_push \
  CentOS7.Dockerfile \
  '' \
  'nightly' \
  "*el7*.rpm" \
  ${NIGHTLY_PYTHON2_PATH}

build_and_push \
  CentOS7.Dockerfile \
  '' \
  'nightly_centos7' \
  "*el7*.rpm" \
  ${NIGHTLY_PYTHON2_PATH}

build_and_push \
  UbuntuXenial.Dockerfile \
  '' \
  'nightly_ubuntu16.04' \
  "mantidnightly_*xenial*.deb" \
  ${NIGHTLY_PYTHON2_PATH}

build_and_push \
  UbuntuXenial.Dockerfile \
  '' \
  'nightly_ubuntu16.04_python3' \
  "mantidnightly-python3_*xenial*.deb" \
  ${NIGHTLY_PYTHON3_PATH}

# Logout of Docker Hub
docker --config=${WORKSPACE}/.docker logout

# Remove artifacts
rm -r ${ARTIFACT_DIR}
