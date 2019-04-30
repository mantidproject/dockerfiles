# Mantid development environment in Docker

Docker container for building, testing and developing Mantid.

## Base images and versions

There are images for each base OS:

- [`mantidproject/mantid-development-centos7`](https://hub.docker.com/r/mantidproject/mantid-development-centos7/) - CentOS 7
- [`mantidproject/mantid-development-ubuntubionic`](https://hub.docker.com/r/mantidproject/mantid-development-ubuntubionic/) - Ubuntu 18.04 (Bionic)
- [`mantidproject/mantid-development-ubuntuxenial`](https://hub.docker.com/r/mantidproject/mantid-development-ubuntuxenial/) - Ubuntu 16.04 (Xenial)

Typically you'd want to use the `latest` tag.
This corresponds to the latest version of the developer package and the latest revision of the [paraview-build](https://github.com/mantidproject/paraview-build) script for the particular base OS.

If you do need a specific developer package version then they are available as tags.
Tags follow the naming convention of `devpkg-VER_pv-REV`, where `VER` is the developer package version installed and `REV` is the Git revision of the [paraview-build](https://github.com/mantidproject/paraview-build) script used to build ParaView.

## Usage

The images contain three directories `/mantid_src`, `/mantid_build` and `/mantid_data` which are to be used for the source, build and CMake external data directories respectively.
It is recommended to have these directories mounted to locations on the host filesystem. Reasons being:

- Using your existing SCM, editors, etc. (you modify the code on the host filesystem as you will have probably already been doing)
- Using common external data for host builds and all container builds
- Running a container built or packaged Mantid on the host (assuming an appropriate host system and base image)

To ensure file permissions are handled correctly if mapping volumes to your host filesystem you must pass the `PUID` and `PGID` environment variables when starting a container, these should be set to your user ID and group ID respectively.

The `mantid_development.sh` script can be used to start a container, this script takes four parameters:
```sh
./mantid_development.sh [os] [source] [build] [external data]
```

`[os]` is the image variant you want to use (one of `centos7`, `ubuntuxenial` or `ubuntubionic`).

`[source]`, `[build]` and `[external data]` are the volumes which will be mounted as the source (root of the Mantid Git repository), build and CMake external data directories.
These can either be paths to the host filesystem or names of Docker volumes.

This will give you a `bash` shell in the build directory.
From here you can run `cmake` and your build tool of choice just as you would on your host OS.
Inside the container you will have the username `abc` which is a standard (i.e. non-root) user with `sudo` ability.

The `mantid_development.sh` (and `mantid_development_x11docker.sh`) scripts may need to be modified to suit your system and the environment that you are running them under.
In their current state they are a reasonable default.

All images contain a script (`$HOME/configure.sh`) which will perform a sensible CMake configuration ready for building.
Of course, this can be done manually if a specific configuration is required, however the script should be inspected to find common paths, etc.

### GUI

For running GUI parts of Mantid (i.e. MantidPlot and workbench) the easiest option is to use [`x11docker`](https://github.com/mviereck/x11docker) via `mantid_development_x11docker.sh`:
```sh
./bin/mantid_development_x11docker.sh [os] [source] [build] [external data] [cmd]
```

If you don't want to or can't use `x11docker` then you can try using simple X server mapping (see section below).

### Python 3

The required packages for building Mantid against Python 3 (as described [here](http://developer.mantidproject.org/Python3.html#id2)) are installed on the Ubuntu Xenial and Bionic images.
If you wish to build against Python 3 you need to specify the `-DPYTHON_EXECUTABLE=/usr/bin/python3` parameter to `cmake` and append `-python3` to the ParaView directory.

### Network proxy

One way to get networking to work over a proxy server is to directly use the host system's networking from Docker.
First, one needs to enable port forwarding.
On Ubuntu 16.04 this can be done by
```sh
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT
```

Next, the container has to be launched with the `--network host` option in `docker run` command.
To actually specify the proxy settings, pass `--env http_proxy="http://proxy.domain.tv:2323"` and `--env https_proxy="https://proxy.domain.tv:5555"` to the command.

### Advanced/non-standard usage

The `mantid_development.sh` and `mantid_development_x11docker.sh` scripts are the bare minimum requirements for developing under Docker.
This section gives some examples of additional arguments you may want to include in those scripts for specific purposes.

All examples are arguments to `docker run`.
If you'd like to use any with `x11docker` you must pass them in the manner shown in the `mantid_development_x11docker.sh`.

#### Debugging

Removes security restrictions that would usually prevent a debugger from running correctly.
Tested with GDB.

```sh
--security-opt seccomp=unconfined
--cap-add=SYS_PTRACE
```

#### X server access

Adds X server forwarding for "standard" Docker use (i.e. not `x11docker`).
Host IPC namespacing is required for some Qt functionality.

```sh
--env DISPLAY="$DISPLAY"
--volume "/tmp/.X11-unix:/tmp/.X11-unix:ro"
--volume "$HOME/.Xauthority:/home/abc/.Xauthority:ro"
--ipc=host
```

#### Network access

Some network functionality (e.g. live streaming) may require (or at least become easier with) host network access.

```sh
--net=host
```

#### Persistent home directory

Useful for disabling the painfully annoying "Welcome to Mantid!" splash screen.
Also persisting IDF updates, shell history and such.

```sh
--volume mantid_development_home:/home/abc
```

#### Providing access to data

```sh
man docker-run
```
