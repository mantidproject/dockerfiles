#!/bin/bash

IMAGE="mantidproject/mantid"
BUILD_LOG_DIR="build_logs"

function build_image {
  DOCKERFILE=$1
  TAG=$2

  mkdir -p ${BUILD_LOG_DIR}
  docker build \
    --no-cache \
    --file=${DOCKERFILE} \
    --tag=${IMAGE}:${TAG} \
    . | tee "${BUILD_LOG_DIR}/${TAG}.log"
}

build_image Dockerfile_CentOS7_Nightly nightly
build_image Dockerfile_CentOS7_Nightly nightly_centos7
build_image Dockerfile_Ubuntu16.04_Nightly nightly_ubuntu16.04
