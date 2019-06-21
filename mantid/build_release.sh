#!/bin/bash

VERSION=$1
IMAGE="mantidproject/mantid"

# Load build tools
. build_helpers.sh

function get_package {
  curl -L --output "${1}" "${2}"
}

# Download RHEL 7 package
PACKAGE_RHEL7="./mantid_rhel_7.rpm"
get_package ${PACKAGE_RHEL7} "https://github.com/mantidproject/mantid/releases/download/v${VERSION}/mantid-${VERSION}-1.el7.x86_64.rpm"

# Download Ubuntu Xenial package
PACKAGE_UBUNTU_XENIAL="./mantid_ubuntu_xenial.deb"
get_package ${PACKAGE_UBUNTU_XENIAL} "https://github.com/mantidproject/mantid/releases/download/v${VERSION}/mantid_${VERSION}-0ubuntu1_xenial1_amd64.deb"

MANTID_PATH="/opt/Mantid/bin/"

# "latest" tag (default to CentOS 7)
build_image \
  CentOS7.Dockerfile \
  "$VERSION" \
  latest \
  "$PACKAGE_RHEL7" \
  "$MANTID_PATH"

exit

# "latest" CentOS 7 tag
build_image \
  CentOS7.Dockerfile \
  "$VERSION" \
  latest_centos7 \
  "$PACKAGE_RHEL7" \
  "$MANTID_PATH"

# "latest" Ubuntu 16.04 (xenial) tag
build_image \
  UbuntuXenial.Dockerfile \
  "$VERSION" \
  latest_ubuntu16.04 \
  "$PACKAGE_UBUNTU_XENIAL" \
  "$MANTID_PATH"

# Version only tag (default to CentOS 7)
build_image \
  CentOS7.Dockerfile \
  "$VERSION" \
  "$VERSION" \
  "$PACKAGE_RHEL7" \
  "$MANTID_PATH"

# Versioned CentOS 7 tag
build_image \
  CentOS7.Dockerfile \
  "$VERSION" \
  "${VERSION}_centos7" \
  "$PACKAGE_RHEL7" \
  "$MANTID_PATH"

# Versioned Ubuntu 16.04 (xenial) tag
build_image \
  UbuntuXenial.Dockerfile \
  "$VERSION" \
  "${VERSION}_ubuntu16.04" \
  "$PACKAGE_UBUNTU_XENIAL" \
  "$MANTID_PATH"
