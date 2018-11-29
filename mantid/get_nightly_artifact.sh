#!/bin/bash

PLATFORM=$1
PACKAGE_EXT=$2
LOCAL_FILENAME=$3

JOB_URL="http://builds.mantidproject.org/view/Master%20Pipeline/job/master_clean-${PLATFORM}/lastSuccessfulBuild"

# Find the last successful build
API_URL="${JOB_URL}/api/json?tree=artifacts[*]"
FILENAME=`curl --globoff ${API_URL} | jq --raw-output .artifacts[].relativePath | grep ${PACKAGE_EXT}`
echo "Found package: ${FILENAME}"

# Download the installer artifact
ARTIFACT_URL="${JOB_URL}/artifact/${FILENAME}"
curl --output ${LOCAL_FILENAME} ${ARTIFACT_URL}
