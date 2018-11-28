#!/bin/bash

OS=$1
SOURCE_DIR=$2
BUILD_DIR=$3
DATA_DIR=$4
CMD=$5

x11docker \
  --xpra \
  --hostipc \
  -- "-v ${SOURCE_DIR}:/mantid_src -v ${BUILD_DIR}:/mantid_build -v ${DATA_DIR}:/mantid_data" \
  mantidproject/mantid-development-${OS}:latest \
  ${CMD}
