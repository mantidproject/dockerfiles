#!/bin/bash

ORG="mantidproject"

PARAVIEW_BUILD_REVISION="8a3b1a4"
BUILD_LOG_DIR="build_logs"

function build_tag {
  DEV_PACKAGE_VERSION=$1
  echo "devpkg-${DEV_PACKAGE_VERSION}_pv-${PARAVIEW_BUILD_REVISION}"
}
