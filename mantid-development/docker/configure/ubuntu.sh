#!/bin/sh

set -x

cd /mantid_build && cmake \
  -G Ninja \
  -DMAKE_VATES=ON \
  -DParaView_DIR=/paraview/build/ParaView-5.4.1/ \
  -DENABLE_WORKBENCH=ON \
  -DMANTID_DATA_STORE=/mantid_data/ \
  /mantid_src
