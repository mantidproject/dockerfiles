#!/bin/bash
#
# Create and push a bare bones container image with nothing but the coverity distribution tarball
#
# usage: ./cov-analysis-push.sh <filename>
#
# example:
#   ./cov-analysis-push.sh "cov-analysis-linux64-2024.12.1.tar.gz"
#

set -euo pipefail

filepath="$(pwd -P)/${1%/*}"
filepath="${filepath:-.}"
file="${1##*/}"
file_strip="${file%%.tar.gz}"
image_name="${file_strip%-*}"
tag="${file_strip##*-}"
owner="mantidproject"

cd "${filepath}"
test -f "./${file}"

podman build \
  --squash-all \
  --format oci \
  --annotation "org.opencontainers.image.title=Coverity Scan Build Tool" \
  --annotation "org.opencontainers.image.description=Coverity Scan Build Tool version ${tag}" \
  --tag "ghcr.io/${owner}/${image_name}:${tag}" \
  --tag "ghcr.io/${owner}/${image_name}:latest" \
  --file - . <<-__EOF__
	# syntax=docker/dockerfile:1
	FROM scratch
	COPY ./${file} /
__EOF__

cd -

set -x

#
# Print the oci registry mantifest JSON
#
skopeo inspect --raw containers-storage:ghcr.io/mantidproject/cov-analysis-linux64:2024.12.1 | jq -r '.'
#
# containers-storage: transport reads from podman's local image store instead of remote
#
#

podman push "ghcr.io/${owner}/${image_name}:${tag}"
podman push "ghcr.io/${owner}/${image_name}:latest"

#
# Print the oci registry mantifest JSON as rendered on remote
#
skopeo inspect --raw docker://ghcr.io/mantidproject/cov-analysis-linux64:2024.12.1 | jq -r '.'

