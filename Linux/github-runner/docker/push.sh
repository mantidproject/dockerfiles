#!/bin/bash

. build_common.sh

docker push \
  ${REGISTRY}/${ORG}/github-runner-alma9:${VERSION} \
