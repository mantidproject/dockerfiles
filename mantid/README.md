# Mantid in Docker

Run [mantid](https://www.mantidproject.org) in Docker.

## Usage

MantidPlot:
```sh
docker run \
  --rm \
  --ipc=host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  mantidproject/mantid:3.13.0_ubuntu16.04 \
  mantidplot
```

Note that the instrument view does not work using this method.

Mantid Python:
```sh
docker run \
  --rm -it \
  mantidproject/mantid:3.13.0_ubuntu16.04 \
  mantidpython
```

[x11docker](https://github.com/mviereck/x11docker) can be used to enable
advanced graphics features (instrument view, VSI, etc.) and is the only way to
run the new workbench:
```sh
x11docker \
  --hostipc \
  --xpra \
  mantidproject/mantid /
  mantidplot
```

You will more than likely want to assign some volumes to access data too.

## Tags/versions

The following tags are available:

- `latest` - Latest release with CentOS 7 base image
- `x.y.z` - Release *x.y.z* with CentOS 7 base image
- `latest_centos7` - Latest release with CentOS 7 base image
- `x.y.z_centos7` - Release *x.y.z* with CentOS 7 base image
- `latest_ubuntu16.04` - Latest release with Ubuntu 16.04 (xenial) base image
- `x.y.z_ubuntu16.04` - Release *x.y.z* with Ubuntu 16.04 (xenial) base image

See [here](https://hub.docker.com/r/mantidproject/mantid/tags/) For a full list.
