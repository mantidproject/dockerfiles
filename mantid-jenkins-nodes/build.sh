#!/bin/sh

docker build \
  --file Dockerfile_UbuntuXenial \
  -t mantidproject/jenkins-node:ubuntuxenial \
  .

docker build \
  --file Dockerfile_UbuntuBionic \
  -t mantidproject/jenkins-node:ubuntubionic \
  .
