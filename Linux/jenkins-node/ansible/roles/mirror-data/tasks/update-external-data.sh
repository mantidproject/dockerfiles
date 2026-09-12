#! /bin/bash

SERVER_IP=${1}
HOST_NAME=${2}
USER_NAME=${3}

RSYNC_PROCESS_IDS=$(pidof rsync)

printf "%(%H:%M:%S)T "

if [ -z "${RSYNC_PROCESS_IDS}" ]; then
        echo "running rsync..."
        rsync -azvW --perms -o -g  $USER_NAME@$SERVER_IP:/external-data/MD5/ /${HOST_NAME}_external_data/MD5/
else
        echo "rsync is already running. Skipping this time..."
fi
