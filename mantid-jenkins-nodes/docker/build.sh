#!/bin/sh

docker build \
  --file CentOS7.Dockerfile \
  -t mantidproject/jenkins-node:centos7 \
  .

docker build \
  --file UbuntuXenial.Dockerfile \
  -t mantidproject/jenkins-node:ubuntuxenial \
  .

docker build \
  --file UbuntuBionic.Dockerfile \
  -t mantidproject/jenkins-node:ubuntubionic \
  .
