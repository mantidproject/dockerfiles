#!/bin/bash

. build_common.sh

docker push \
  ${REGISTRY}/${ORG}/jenkins-node-alma9:${VERSION} \

docker push \
  ${REGISTRY}/${ORG}/jenkins-node-alma9:latest \
