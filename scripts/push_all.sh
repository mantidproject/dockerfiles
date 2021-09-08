#!/bin/bash

# exit when any command fails
set -e

ROOT_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"

cd $ROOT_DIR/development/docker/
./push.sh
cd $ROOT_DIR/jenkins-node/docker-images
./push.sh
