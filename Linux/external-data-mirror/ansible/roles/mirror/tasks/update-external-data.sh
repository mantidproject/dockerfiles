#! /bin/sh

SERVER_IP=${1}

RSYNC_PROCESS_IDS=$(pidof rsync)

if [[ -z $RSYNC_PROCESS_IDS ]]; then
        rsync -az --perms -o -g  $SERVER_IP:/srv/$SERVER_IP/ftp/external-data/MD5/ /external-data/MD5/
else
        echo "rsync is already running. Skipping this time..."
fi