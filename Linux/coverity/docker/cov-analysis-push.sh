#!/bin/bash

#
# Create and push a bare bones container image with nothing but the coverity distribution tarball
#
#
#   usage:  ./cov-analysis-push.sh <filename>
#
#   example:
#           ./cov-analysis-push.sh "cov-analysis-linux64-2024.12.1.tar.gz"
#

filepath="$(pwd -P)/${1%/*}"       # isolate the path
filepath="${filepath%/*}"
filepath="${filepath:-.}"          # if no path specified set as .
file="${1##*/}"                    # isolate the filename
file_strip="${file%%.tar.gz}"      # strip the .tar.gz extension
image_name="${file_strip%-*}"      # isolate the image name
tag="${file_strip##*-}"            # isolate the tag (version)

owner="mantidproject"

cd ${filepath}      || exit 1
test -f ./${file}   || exit 1

docker build \
  --tag "ghcr.io/${owner}/${image_name}:${tag}" \
  --tag "ghcr.io/${owner}/${image_name}:latest" \
  --file - . <<-__EOF__

	FROM scratch
	LABEL org.opencontainers.image.description="Coverity Scan Build Tool v${tag}"
	COPY ./${file} /

__EOF__

cd -

set -x
docker push "ghcr.io/${owner}/${image_name}:${tag}"
docker push "ghcr.io/${owner}/${image_name}:latest"
