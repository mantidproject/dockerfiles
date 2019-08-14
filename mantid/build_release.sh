#!/bin/bash

VERSION="$1"
PACKAGE_RHEL7="$2"

IMAGE='mantidproject/mantid'

# Load build tools
. build_helpers.sh

MANTID_PATH='/opt/Mantid/bin/'

# "latest" tag (default to CentOS 7)
build_image \
  'CentOS7.Dockerfile' \
  "$VERSION" \
  'latest' \
  "$PACKAGE_RHEL7" \
  "$MANTID_PATH"

# Version only tag (default to CentOS 7)
build_image \
  'CentOS7.Dockerfile' \
  "$VERSION" \
  "$VERSION" \
  "$PACKAGE_RHEL7" \
  "$MANTID_PATH"
