#!/bin/bash

# exit when any command fails
set -e

ROOT_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"

$ROOT_DIR/development/docker/push.sh
$ROOT_DIR/jenkins-node/docker-images/os-builder/push.sh
$ROOT_DIR/jenkins-node/docker-images/static-analysis/push.sh
