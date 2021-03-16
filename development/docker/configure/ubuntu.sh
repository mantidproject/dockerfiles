#!/bin/sh

set -x

cd /mantid_build && cmake \
  -G Ninja \
  -DENABLE_WORKBENCH=ON \
  -DMANTID_DATA_STORE=/mantid_data/ \
  /mantid_src
