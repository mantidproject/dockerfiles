#!/bin/bash

OS=$1
SOURCE_DIR=$2
BUILD_DIR=$3
DATA_DIR=$4
CMD=$5

PUID=`id -u`
PGID=`id -g`

x11docker \
  --hostipc \
  --cap-default \
  --no-init \
  --user=RETAIN \
  -- "--volume ${SOURCE_DIR}:/mantid_src --volume ${BUILD_DIR}:/mantid_build --volume ${DATA_DIR}:/mantid_data --env PUID=${PUID} --env PGID=${PGID}" \
  mantidproject/mantid-development-${OS}:latest \
  ${CMD}
