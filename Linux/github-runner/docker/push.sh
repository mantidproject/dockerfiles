#!/bin/bash

. build_common.sh

docker push \
  ${REGISTRY}/${ORG}/jenkins-node-centos7-slim:${VERSION} \
