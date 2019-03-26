#!/bin/bash

VERSION=$1
IMAGE="mantidproject/mantid"

docker push "${IMAGE}:latest"
docker push "${IMAGE}:latest_centos7"
docker push "${IMAGE}:latest_ubuntu16.04"
docker push "${IMAGE}:${VERSION}"
docker push "${IMAGE}:${VERSION}_centos7"
docker push "${IMAGE}:${VERSION}_ubuntu16.04"
