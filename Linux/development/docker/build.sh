#!/bin/bash

. build_common.sh

function build_image {
  DOCKERFILE=$1
  OS=$2
  VERSION=$3

  IMAGE="mantid-development-${OS}"
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

build_image Alma9.Dockerfile alma9 ${VERSION}
