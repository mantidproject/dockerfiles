#!/bin/sh

set -ex

scp bin/* "$1":~
scp -r netdata "$1":~
