#!/bin/sh

. build_common_slim.sh

docker push \
  ${REGISTRY}/${ORG}/jenkins-node-centos7-slim:${VERSION} \

docker push \
  ${REGISTRY}/${ORG}/jenkins-node-centos7-slim:latest \
