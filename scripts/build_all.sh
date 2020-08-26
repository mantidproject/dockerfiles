#!/bin/bash

# exit when any command fails
set -e

ROOT_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"

# Build base development images
cd $ROOT_DIR/development/docker/
./build.sh

# Build jenkins-node using previous images
cd $ROOT_DIR/jenkins-node/docker-images/os-builder/
./build.sh

# Build static analysis images
cd $ROOT_DIR/jenkins-node/docker-images/static-analysis/
./build.sh

