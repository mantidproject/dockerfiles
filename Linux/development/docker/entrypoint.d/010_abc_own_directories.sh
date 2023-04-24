#!/bin/bash

set -x

# Take ownership of working directories
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /mantid_src
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /mantid_build
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /mantid_data
