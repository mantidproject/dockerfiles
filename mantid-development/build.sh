#!/bin/bash

function build_image {
  DOCKERFILE=$1
  OS=$2
  VERSION=$3

  echo "Building tag ${TAG} from Dockerfile ${DOCKERFILE}"

  docker build \
    -f ${DOCKERFILE} \
    --build-arg DEV_PACKAGE_VERSION=${VERSION} \
    -t mantidproject/mantid-development-${OS}:${VERSION} \
    .

  docker build \
    -f ${DOCKERFILE} \
    --build-arg DEV_PACKAGE_VERSION=${VERSION} \
    -t mantidproject/mantid-development-${OS}:latest \
    .

  echo
}

build_image Dockerfile_CentOS7 centos7 "1.29"
build_image Dockerfile_UbuntuBionic ubuntubionic "1.3.8"
build_image Dockerfile_UbuntuXenial ubuntuxenial "1.3.8"
