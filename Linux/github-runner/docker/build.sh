#!/bin/bash

. build_common.sh

docker build \
  --file=Alma9.Dockerfile \
  --tag=${REGISTRY}/${ORG}/github-runner-alma9:${VERSION} \
  .
