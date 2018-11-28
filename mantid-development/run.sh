#!/bin/bash

OS=$1
SOURCE_DIR=$2
BUILD_DIR=$3
DATA_DIR=$4

docker run \
  --rm -it \
  --ipc=host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v ${SOURCE_DIR}:/mantid_src \
  -v ${BUILD_DIR}:/mantid_build \
  -v ${DATA_DIR}:/mantid_data \
  mantidproject/mantid-development-${OS}:latest
