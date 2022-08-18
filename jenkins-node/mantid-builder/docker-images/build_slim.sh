#!/bin/sh

. build_common_slim.sh

docker build \
  --file=CentOS7Slim.Dockerfile \
  --tag=${REGISTRY}/${ORG}/jenkins-node-centos7-slim:${VERSION} \
  .

docker build \
  --file=CentOS7Slim.Dockerfile \
  --tag=${REGISTRY}/${ORG}/jenkins-node-centos7-slim:latest \
  .
