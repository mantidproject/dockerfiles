#!/bin/bash

. build_common_slim.sh

function push_image_slim {
  OS=$1
  VERSION=$2

  IMAGE="mantid-development-${OS}-slim"
  TAG="$VERSION"

  docker push \
    ${REGISTRY}/${ORG}/${IMAGE}:${TAG}

  docker push \
    ${REGISTRY}/${ORG}/${IMAGE}:latest
}

push_image_slim centos7 "0.1"
