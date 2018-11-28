#!/bin/bash

IMAGE="mantid"
VERSION=$1

# Version only tag (default to CentOS 7)
docker build \
  -f Dockerfile_CentOS7 \
  -t mantidproject/mantid:${VERSION} \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# "latest" tag (default to CentOS 7)
docker build \
  -f Dockerfile_CentOS7 \
  -t mantidproject/mantid:latest \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# Versioned CentOS 7 tag
docker build \
  -f Dockerfile_CentOS7 \
  -t mantidproject/mantid:${VERSION}_centos7 \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# "latest" CentOS 7 tag
docker build \
  -f Dockerfile_CentOS7 \
  -t mantidproject/mantid:latest_centos7 \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# Versioned Ubuntu 16.04 (xenial) tag
docker build \
  -f Dockerfile_Ubuntu16.04 \
  -t mantidproject/mantid:${VERSION}_ubuntu16.04 \
  --build-arg MANTID_VERSION=${VERSION} \
  .

# "latest" Ubuntu 16.04 (xenial) tag
docker build \
  -f Dockerfile_Ubuntu16.04 \
  -t mantidproject/mantid:latest_ubuntu16.04 \
  --build-arg MANTID_VERSION=${VERSION} \
  .
