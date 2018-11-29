#!/bin/bash

IMAGE="mantidproject/mantid"
VERSION=$1

# Version only tag (default to CentOS 7)
docker build \
  -f Dockerfile_CentOS7_Release \
  -t ${IMAGE}:${VERSION} \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# "latest" tag (default to CentOS 7)
docker build \
  -f Dockerfile_CentOS7_Release \
  -t ${IMAGE}:latest \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# Versioned CentOS 7 tag
docker build \
  -f Dockerfile_CentOS7_Release \
  -t ${IMAGE}:${VERSION}_centos7 \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# "latest" CentOS 7 tag
docker build \
  -f Dockerfile_CentOS7_Release \
  -t ${IMAGE}:latest_centos7 \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# Versioned Ubuntu 16.04 (xenial) tag
docker build \
  -f Dockerfile_Ubuntu16.04_Release \
  -t ${IMAGE}:${VERSION}_ubuntu16.04 \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# "latest" Ubuntu 16.04 (xenial) tag
docker build \
  -f Dockerfile_Ubuntu16.04_Release \
  -t ${IMAGE}:latest_ubuntu16.04 \
  --build-arg MANTID_VERSION=${VERSION} \
  .
