#!/bin/bash

. build_common.sh

docker build \
  --file=RockyLinux8.Dockerfile \
  --tag=${REGISTRY}/${ORG}/github-runner-rockylinux8:${VERSION} \
  .
