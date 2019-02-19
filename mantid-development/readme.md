# Mantid development environment in Docker

Docker container for building, testing and developing  Mantid.

## Base images and versions

There are images for each base OS:

- [`mantidproject/mantid-development-centos7`](https://hub.docker.com/r/mantidproject/mantid-development-centos7/) - CentOS 7
- [`mantidproject/mantid-development-ubuntubionic`](https://hub.docker.com/r/mantidproject/mantid-development-ubuntubionic/) - Ubuntu 18.04 (Bionic)
- [`mantidproject/mantid-development-ubuntuxenial`](https://hub.docker.com/r/mantidproject/mantid-development-ubuntuxenial/) - Ubuntu 16.04 (Xenial)

Typically you'd want to use the `latest` tag which corresponds to the latest
version of the developer package and the latest revision of the
[paraview-build](https://github.com/mantidproject/paraview-build) script for the
particular base OS.

If you do need a specific developer package version then they are available as
tags. Tags follow the naming convention of `devpkg-VER_pv-REV`, where `VER` is
the developer package version installed and `REV` is the Git revision of the
[paraview-build](https://github.com/mantidproject/paraview-build) script used to
build ParaView.

## Usage

The images contain three directories `/mantid_src`, `/mantid_build` and
`/mantid_data` which are to be used for the source, build and CMake external
data directories respectively. `/mantid_data` is the target of a symbolic link
from the default external data location configured in CMake.

It is recommended to have these directories mounted to locations on the host
filesystem. Reasons being:

- Using your existing SCM, editors, etc. (you modify the code on the host
  filesystem as you will have probably already been doing)
- Using common external data for host builds and all container builds
- Running a container built or packaged Mantid on the host (assuming an
  appropriate host system and base image)

To ensure file permissions are handled correctly if mapping volumes to your host
filesystem you must pass the `PUID` and `PGID` environment variables when
starting a container, these should be set to your user ID and group ID
respectively.

The `mantid_development.sh` script can be used to start a container, this script
takes four parameters:
```sh
./mantid_development.sh [os] [source] [build] [external data]
```

`[os]` is the image variant you want to use (one of `centos7`, `ubuntuxenial` or
`ubuntubionic`).

`[source]`, `[build]` and `[external data]` are the volumes which will be
mounted as the source (root of the Mantid Git repository), build and CMake
external data directories. These can either be paths to the host filesystem or
names of Docker volumes.

This will give you a `bash` shell in the build directory. From here you can run
`cmake` and your build tool of choice just as you would on your host OS. Inside
the container you will have the username `abc` which is a standard (i.e.
non-root) user with `sudo` ability.

The following CMake command will correctly set up your source, external data and
ParaView directories (as well as enabling Vates and Workbench). This should be
the used to configure your new build directory.

```sh
cmake \
  -G Ninja \
  -DMAKE_VATES=ON \
  -DParaView_DIR=/paraview/build/ParaView-5.4.1/ \
  -DENABLE_WORKBENCH=ON \
  /mantid_src
```

For CentOS 7 you'll have to use `cmake3` (instead of `cmake`) and wrap the
initial CMake invocation in `scl anable devtoolset-7` to find the correct
compiler (as described
[here](http://developer.mantidproject.org/BuildingWithCMake.html#from-the-command-line)).

### GUI

For running GUI parts of Mantid (i.e. MantidPlot and workbench) the easiest
option is to use [`x11docker`](https://github.com/mviereck/x11docker) via
`mantid_development_x11docker.sh`:
```sh
./bin/mantid_development_x11docker.sh [os] [source] [build] [external data] [cmd]
```

If you don't want to or can't use `x11docker` then you can try using simple X
server mapping (this does not seem to work for the workbench). This is already
configured in the `mantid_development.sh` script, all that is needed in addition is to allow
connections to the host X server.

```sh
xhost +
./mantid_development.sh [os] [source] [build] [external data]
```

### Python 3

The required packages for building Mantid against Python 3 (as described
[here](http://developer.mantidproject.org/Python3.html#id2)) are installed on
the Ubuntu Xenial and Bionic images so if you wish to build against Python 3 you
only need to specify the `-DPYTHON_EXECUTABLE=/usr/bin/python3` parameter to
`cmake`.

### Network proxy

One way to get networking to work over a proxy server is to directly use the host system's networking from Docker. First, one needs to enable port forwarding. On Ubuntu 16.04 this can be done by
```sh
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT
```

Next, the container has to be launced with the `--network host` option in `docker run` command. To actually specify the proxy settings, pass `--env http_proxy="http://proxy.domain.tv:2323"` and `--env https_proxy="https://proxy.domain.tv:5555"` to the command.
