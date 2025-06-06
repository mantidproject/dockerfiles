#!/usr/bin/env bash
# Control server(s) on an Openstack cloud.
# The openstack command must be available on the PATH.
#
# This script assumes a ~/.config/openstack/clouds.yaml
# exists containing credentials for the project that
# contains the servers. This can be created and downloaded
# from the Identity->Appplication Credentials section of the
# OpenStack UI.

# cloudname as in ~/.config/openstack/clouds/yaml
CLOUDNAME=openstack
# Server details
IMAGE=ubuntu-jammy-22.04-nogui
FLAVOUR=l6.c32
SECGROUP=default
KEYNAME= # Key pair name from openstack
INSTANCENAME_PREFIX=isis-cloud-linux-b
INSTANCECOUNT=10
NETWORK=Internal

# Functions
function up() {
  openstack \
    --os-cloud $CLOUDNAME \
    server create \
    --image $IMAGE \
    --flavor $FLAVOUR \
    --security-group $SECGROUP \
    --key-name $KEYNAME \
    --min $INSTANCECOUNT \
    --max $INSTANCECOUNT \
    --network $NETWORK \
    $INSTANCENAME_PREFIX
  echo "Note: The default openstack output above shows only a single instance even if more were requested."
  sleep 2
  echo "Full instance list:"
  openstack \
    --os-cloud $CLOUDNAME \
    server list
}

function down() {
  for i in `seq $INSTANCECOUNT`;
  do
    openstack \
      --os-cloud $CLOUDNAME \
      server delete $INSTANCENAME_PREFIX-$i;
  done  
}

function fatal() {
  >&2 echo $1
  exit 1
}

# is openstack command available?
if ! command -v "openstack" &> /dev/null; then
  fatal "openstack command not available. Have you activated the environment?"
fi

case $1 in
  up) up
    ;;
  down) down
    ;;
  *)
    echo Unknown command $1. Use 'up' or 'down'.
esac

