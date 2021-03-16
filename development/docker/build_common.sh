#!/bin/bash

ORG="mantidproject"

BUILD_LOG_DIR="build_logs"

function build_tag {
  DEV_PACKAGE_VERSION=$1
  echo "devpkg-${DEV_PACKAGE_VERSION}"
}
