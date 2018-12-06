#!/bin/bash

IMAGE="mantidproject/mantid"
BUILD_LOG_DIR="build_logs"

function build_image {
  DOCKERFILE=$1
  TAG=$2
  PACKAGE=$3

  mkdir -p ${BUILD_LOG_DIR}
  docker build \
    --no-cache \
    --file=${DOCKERFILE} \
    --tag=${IMAGE}:${TAG} \
    --build-arg PACKAGE=${PACKAGE} \
    . | tee "${BUILD_LOG_DIR}/${TAG}.log"
}
