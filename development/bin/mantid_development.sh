#!/bin/bash

OS="$1"
SOURCE_DIR="$2"
BUILD_DIR="$3"
DATA_DIR="$4"

docker run \
  --name "mantid_development_$OS" \
  --rm \
  --interactive \
  --tty \
  --env PUID=`id -u` \
  --env PGID=`id -g` \
  --volume "$SOURCE_DIR:/mantid_src" \
  --volume "$BUILD_DIR:/mantid_build" \
  --volume "$DATA_DIR:/mantid_data" \
  --volume "mantid_development_ccache_$OS:/ccache" \
  "mantidproject/mantid-development-$OS:latest"
