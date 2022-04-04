#!/bin/sh

here="$( cd "$(dirname "$0")" ; pwd -P )"

set -ex

scp "$here/bin/"* "$1":~
scp -r "$here/netdata" "$1":~
