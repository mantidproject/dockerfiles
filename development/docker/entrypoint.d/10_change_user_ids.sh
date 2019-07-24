#!/bin/bash

set -x

PUID=${PUID:-911}
PGID=${PGID:-911}

# Set target user's IDs to match that of the "external"/"host" user
groupmod --non-unique --gid ${PGID} ${TARGET_USERNAME}
usermod --non-unique --uid ${PUID} ${TARGET_USERNAME}
