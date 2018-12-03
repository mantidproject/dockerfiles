# Mantid development environment in Docker

Docker container for building Mantid.

Currently contains requirements for a "basic" build, i.e. just compiling Mantid
and running test suites. ParaView/VSI is not included (yet).

## Base images and versions

There are images for each base OS:

- [`mantidproject/mantid-development-centos7`](https://hub.docker.com/r/mantidproject/mantid-development-centos7/) - CentOS 7
- [`mantidproject/mantid-development-ubuntubionic`](https://hub.docker.com/r/mantidproject/mantid-development-ubuntubionic/) - Ubuntu 18.04 (Bionic)
- [`mantidproject/mantid-development-ubuntuxenial`](https://hub.docker.com/r/mantidproject/mantid-development-ubuntuxenial/) - Ubuntu 16.04 (Xenial)

Typically you'd want to use the `latest` tag which corresponds to the latest
version of the developer package for the particular base OS. If you do need a
specific developer package version then they are available as tags.

## Usage

The images contain three directories `/mantid_src`, `/mantid_build` and
`/mantid_data` which are to be used for the source, build and CMake external
data directories respectively. It is recommended to have these directories
mounted to locations on the host filesystem. Reasons being:

- Using your existing SCM, editors, etc. (you modify the code on the host
  filesystem as you will have probably already been doing)
- Using common external data for host builds and all container builds
- Running a container built or packaged Mantid on the host (assuming an
  appropriate host system and base image)

Of course Docker volumes could also be used for the build and external data
directories if you will only ever do container builds.

The container can be run like this (replacing `centos7` with the base OS
you care about):

```sh
docker run --rm -it \
  -v /path/to/mantid/source:/mantid_src \
  -v /path/to/mantid/build:/mantid_build \
  -v /path/to/mantid/data:/mantid_data \
  mantidproject/mantid-development-centos7
```

This will give you a `bash` shell in the build directory. From here you can run
`cmake` and your build tool of choice just as you would on your host OS.

When running `cmake` ensure you set the external data location to the
appropriate Docker volume. Ninja is included in the image so you may also want
to specify that.

```sh
cmake -DMANTID_DATA_STORE=/mantid_data -G Ninja /mantid_src
```

For running GUI parts of Mantid (i.e. MantidPlot and workbench) the easiest
option is to use [`x11docker`](https://github.com/mviereck/x11docker):
```sh
x11docker \
  --hostipc \
  --xpra \
  -- "-v /path/to/mantid/source:/mantid_src -v /path/to/mantid/build:/mantid_build -v /path/to/mantid/data:/mantid_data" \
  mantidproject/mantid-development-centos7 \
  mantidplot
```

If you don't want to or can't use `x11docker` then you can try mapping to the
host X server (this does not seem to work for the workbench):
```sh
xhost +
docker run --rm -it \
  --ipc=host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro
  -v /path/to/mantid/source:/mantid_src \
  -v /path/to/mantid/build:/mantid_build \
  -v /path/to/mantid/data:/mantid_data \
  mantidproject/mantid-development-centos7
```

## Python 3

The required packages for building Mantid against Python 3 (as described
[here](http://developer.mantidproject.org/Python3.html#id2)) are installed on
the Ubuntu Xenial and Bionic images so if you wish to build against Python 3 you
only need to specify the `-DPYTHON_EXECUTABLE=/usr/bin/python3` parameter to
`cmake`.
