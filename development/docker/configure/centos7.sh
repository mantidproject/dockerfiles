#!/bin/sh

set -x

cd /mantid_build && scl enable devtoolset-7 "cmake3 \
  -G Ninja \
  -DENABLE_WORKBENCH=ON \
  -DMANTID_DATA_STORE=/mantid_data/ \
  /mantid_src"
