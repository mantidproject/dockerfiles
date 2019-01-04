#!/bin/bash

PARAVIEW_BUILD_REVISION="8a3b1a4"
BUILD_LOG_DIR="build_logs"

mkdir -p ${BUILD_LOG_DIR}

function build_image {
  DOCKERFILE=$1
  OS=$2
  DEV_PACKAGE_VERSION=$3

  ORG="mantidproject"
  IMAGE="mantid-development-${OS}"
  TAG="devpkg-${DEV_PACKAGE_VERSION}_pv-${PARAVIEW_BUILD_REVISION}"

  echo "Building ${ORG}${IMAGE}:${TAG} from ${DOCKERFILE}"

  docker build \
    --file=${DOCKERFILE} \
    --build-arg DEV_PACKAGE_VERSION=${DEV_PACKAGE_VERSION} \
    --build-arg PARAVIEW_BUILD_REVISION=${PARAVIEW_BUILD_REVISION} \
    --tag=${ORG}/${IMAGE}:${TAG} \
    . | tee "${BUILD_LOG_DIR}/${IMAGE}_${TAG}.log"

  docker build \
    --file=${DOCKERFILE} \
    --build-arg DEV_PACKAGE_VERSION=${DEV_PACKAGE_VERSION} \
    --build-arg PARAVIEW_BUILD_REVISION=${PARAVIEW_BUILD_REVISION} \
    --tag=${ORG}/${IMAGE}:latest \
    . | tee "${BUILD_LOG_DIR}/${IMAGE}_latest.log"

  echo
}

build_image CentOS7.Dockerfile centos7 "1.30"
build_image UbuntuBionic.Dockerfile ubuntubionic "1.3.9"
build_image UbuntuXenial.Dockerfile ubuntuxenial "1.3.9"
