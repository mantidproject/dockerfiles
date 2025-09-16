#! /bin/bash

SERVER_IP=${1}

RSYNC_PROCESS_IDS=$(pidof rsync)

printf "%(%H:%M:%S)T "

if [ -z "${RSYNC_PROCESS_IDS}" ]; then
        echo "running rsync..."
        rsync -az --perms -o -g  $SERVER_IP:/external-data/MD5/ /external-data/MD5/
else
        echo "rsync is already running. Skipping this time..."
fi
