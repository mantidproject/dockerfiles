#!/bin/bash

. build_common.sh

function build_image {
  DOCKERFILE=$1
  OS=$2
  DEV_PACKAGE_VERSION=$3

  IMAGE="mantid-development-${OS}"
  TAG=`build_tag ${DEV_PACKAGE_VERSION}`

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

mkdir -p ${BUILD_LOG_DIR}

build_image CentOS7.Dockerfile centos7 "1.31"
build_image UbuntuBionic.Dockerfile ubuntubionic "1.4.1"
build_image UbuntuXenial.Dockerfile ubuntuxenial "1.4.1"
