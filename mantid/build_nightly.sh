#!/bin/bash

IMAGE="mantidproject/mantid"
BUILD_LOG_DIR="build_logs"

function do_build {
  DOCKERFILE=$1
  TAG=$2

  mkdir -p ${BUILD_LOG_DIR}
  docker build --file=${DOCKERFILE} --tag=${IMAGE}:${TAG} . | tee "${BUILD_LOG_DIR}/${TAG}.log"
}

do_build Dockerfile_CentOS7_Nightly nightly
do_build Dockerfile_CentOS7_Nightly nightly_centos7
do_build Dockerfile_Ubuntu16.04_Nightly nightly_ubuntu16
