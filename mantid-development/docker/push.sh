#!/bin/bash

. build_common.sh

function push_image {
  OS=$1
  DEV_PACKAGE_VERSION=$2

  IMAGE="mantid-development-${OS}"
  TAG=`build_tag ${DEV_PACKAGE_VERSION}`

  docker push \
    ${ORG}/${IMAGE}:${TAG}

  docker push \
    ${ORG}/${IMAGE}:latest
}

push_image centos7 "1.30"
push_image ubuntubionic "1.4.0"
push_image ubuntuxenial "1.4.0"
