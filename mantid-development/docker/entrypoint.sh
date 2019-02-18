#!/bin/sh

# Handles setting up the target user (abc) and redirecting the command to be
# executed by them.
# This is all in aid of ensuring that permissions of filesystem mapped volumes
# function correctly and that the root user is not used within the container.

set -x

PUID=${PUID:-911}
PGID=${PGID:-911}

TARGET_USERNAME="abc"

# Set target user's IDs to match that of the "external"/"host" user
groupmod --non-unique --gid ${PGID} ${TARGET_USERNAME}
usermod --non-unique --uid ${PUID} ${TARGET_USERNAME}

# Take ownership of working directories
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /mantid_src
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /mantid_build
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /mantid_data
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /ccache_cache

# Run the supplied command as the target user
CMD=${@:-"bash"}
runuser -u ${TARGET_USERNAME} -- "${CMD}"
