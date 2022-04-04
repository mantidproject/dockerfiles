#!/bin/sh

docker build \
  --file Dockerfile \
  -t mantidproject/jenkins-deployment-tools \
  .
