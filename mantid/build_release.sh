#!/bin/bash

VERSION=$1
IMAGE="mantidproject/mantid"
BUILD_LOG_DIR="build_logs"

function do_build {
  DOCKERFILE=$1
  TAG=$2

  mkdir -p ${BUILD_LOG_DIR}
  docker build --file=${DOCKERFILE} --tag=${IMAGE}:${TAG} --build-arg MANTID_VERSION=${VERSION} . | tee "${BUILD_LOG_DIR}/${TAG}.log"
}

# "latest" tag (default to CentOS 7)
do_build Dockerfile_CentOS7_Release latest

# "latest" CentOS 7 tag
do_build Dockerfile_CentOS7_Release latest_centos7

# "latest" Ubuntu 16.04 (xenial) tag
do_build Dockerfile_Ubuntu16.04_Release latest_ubuntu16.04

# Version only tag (default to CentOS 7)
do_build Dockerfile_CentOS7_Release ${VERSION}

# Versioned CentOS 7 tag
do_build Dockerfile_CentOS7_Release ${VERSION}_centos7

# Versioned Ubuntu 16.04 (xenial) tag
do_build Dockerfile_Ubuntu16.04_Release ${VERSION}_ubuntu16.04

