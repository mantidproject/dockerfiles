#!/bin/bash

. build_common_slim.sh

function build_image_slim {
  DOCKERFILE=$1
  OS=$2
  VERSION=$3

  IMAGE="mantid-development-${OS}-slim"
  TAG="${VERSION}"

  echo "Building ${REGISTRY}/${ORG}/${IMAGE}:${TAG} from ${DOCKERFILE}"

  docker build \
    --file=${DOCKERFILE} \
    --tag=${REGISTRY}/${ORG}/${IMAGE}:${TAG} \
    . | tee "${BUILD_LOG_DIR}/${IMAGE}_${TAG}.log"

  docker build \
    --file=${DOCKERFILE} \
    --tag=${REGISTRY}/${ORG}/${IMAGE}:latest \
    . | tee "${BUILD_LOG_DIR}/${IMAGE}_latest.log"
}

mkdir -p ${BUILD_LOG_DIR}

build_image_slim CentOS7Slim.Dockerfile centos7 "0.1"
