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

PATH="${1%/*}"                     # isolate the path
PATH="${PATH:-.}"                  # if no path specified set as .
FILE="${1##*/}"                    # isolate the filename
FILE_STRIP="${FILE%%.tar.gz}"      # strip the .tar.gz extension
IMAGE_NAME="${FILE_STRIP%-*}"      # isolate the image name
TAG="${FILE_STRIP##*-}"            # isolate the tag (version)

OWNER="mantidproject"

cd ${PATH}          || exit 1
test -f ./${FILE}   || exit 1

docker build -t "ghcr.io/${OWNER}/${IMAGE_NAME}:${TAG}" --file - . <<-__EOF__

	FROM scratch
	COPY ./${FILE} /

__EOF__

cd -

set -x
docker push "ghcr.io/${OWNER}/${IMAGE_NAME}:${TAG}"
docker push "ghcr.io/${OWNER}/${IMAGE_NAME}:latest"
