#!/bin/bash

. build_common.sh

function push_image {
  OS=$1
  VERSION=$2

  IMAGE="mantid-development-${OS}"
  TAG="$VERSION"

  docker push \
    ${REGISTRY}/${ORG}/${IMAGE}:${TAG}

  docker push \
    ${REGISTRY}/${ORG}/${IMAGE}:latest
}

push_image alma9 ${VERSION}
