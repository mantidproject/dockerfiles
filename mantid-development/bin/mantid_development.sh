#!/bin/bash

OS=$1
SOURCE_DIR=$2
BUILD_DIR=$3
DATA_DIR=$4

docker run \
  --rm \
  --interactive \
  --tty \
  --security-opt seccomp=unconfined \
  --ipc=host \
  --env PUID=`id -u` \
  --env PGID=`id -g` \
  --env DISPLAY=$DISPLAY \
  --volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
  --volume $HOME/.Xauthority:/home/abc/.Xauthority:ro \
  --volume ${SOURCE_DIR}:/mantid_src \
  --volume ${BUILD_DIR}:/mantid_build \
  --volume ${DATA_DIR}:/mantid_data \
  --volume mantid_development_ccache:/ccache \
  mantidproject/mantid-development-${OS}:latest
