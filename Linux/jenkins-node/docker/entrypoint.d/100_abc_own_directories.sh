#!/bin/bash

set -x

# Take ownership of additional working directories for Jenkins
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /jenkins_workdir
