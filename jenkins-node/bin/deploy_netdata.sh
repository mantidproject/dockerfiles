#!/bin/bash

function usage {
  echo 'Dockerized Jenkins agent deploy script'
  echo "Usage: $0 [webhook url suffix]"
  exit
}

if [[ $# -ne 1 ]]
then
  usage
fi

# Ensure we have the latest version
echo '=== Pulling latest image'
docker pull netdata/netdata

# Search for any existing container with the given name
EXISTING_CONTAINER_ID=`docker container ls --all --format="{{.ID}}" --filter name='netdata'`

# Stop and remove the container if there is one
if [[ -n ${EXISTING_CONTAINER_ID} ]]
then
  echo "=== Stopping and removing existing container with ID $EXISTING_CONTAINER_ID"
  docker stop "$EXISTING_CONTAINER_ID"
  docker container rm "$EXISTING_CONTAINER_ID"
fi

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PARENT_DIR="$THIS_DIR/.."
NET_DATA_DIR="$PARENT_DIR/netdata"

# Write the alert config script
alarm_config_file="$NET_DATA_DIR/health_alarm_notify.conf"
echo 'SEND_SLACK="YES"' > "$alarm_config_file"
echo 'DEFAULT_RECIPIENT_SLACK="#jenkins-admins"' >> "$alarm_config_file"
echo "SLACK_WEBHOOK_URL=\"https://hooks.slack.com/services/$1\"" >> "$alarm_config_file"


# Start a new container
echo '=== Starting new container'
set -x
docker run \
  --name=netdata \
  --detach \
  --restart=always \
  --net=host \
  --volume "$alarm_config_file":/etc/netdata/health_alarm_notify.conf:ro \
  --volume "$NET_DATA_DIR/health.d":/etc/netdata/health.d:ro \
  --volume /etc/passwd:/host/etc/passwd:ro \
  --volume /etc/group:/host/etc/group:ro \
  --volume /proc:/host/proc:ro \
  --volume /sys:/host/sys:ro \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata
