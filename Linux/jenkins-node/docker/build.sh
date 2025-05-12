#!/bin/bash

. build_common.sh

docker build \
  --file=Alma9.Dockerfile \
  --tag=${REGISTRY}/${ORG}/jenkins-node-alma9:${VERSION} \
  .

docker build \
  --file=Alma9.Dockerfile \
  --tag=${REGISTRY}/${ORG}/jenkins-node-alma9:latest \
  .
