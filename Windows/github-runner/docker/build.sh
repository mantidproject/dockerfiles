#!/bin/bash

. build_common.sh

docker build \
  --file=Win.Dockerfile \
  --tag=${REGISTRY}/${ORG}/github-runner-win:${VERSION} \
  .
