#!/bin/bash

. build_common.sh

docker push \
  ${REGISTRY}/${ORG}/github-runner-win:${VERSION}
