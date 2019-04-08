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

- `nightly` - Most recent nightly build with CentOS 7 base image
- `nightly_centos7` - Most recent nightly build with CentOS 7 base image
- `nightly_ubuntu16.04` - Most recent nightly build with Ubuntu 16.04 (xenial) base image
- `nightly_ubuntu16.04_python3` - Most recent nightly build with Python 3 support with Ubuntu 16.04 (xenial) base image
- `latest` - Latest release with CentOS 7 base image
- `latest_centos7` - Latest release with CentOS 7 base image
- `latest_ubuntu16.04` - Latest release with Ubuntu 16.04 (xenial) base image
- `x.y.z` - Release *x.y.z* with CentOS 7 base image
- `x.y.z_centos7` - Release *x.y.z* with CentOS 7 base image
- `x.y.z_ubuntu16.04` - Release *x.y.z* with Ubuntu 16.04 (xenial) base image

See [here](https://hub.docker.com/r/mantidproject/mantid/tags/) For a full list.

## Building

This details how to build images. This is mostly intended for developers
maintaining the images.

If any part of these steps is unclear don't push anything you create to
DockerHub under the `mantidproject` organisation. By all means build images but
make sure you have done what you expected to do before pushing anything.

### Release

TODO

### Nightly

This should mainly be done by Jenkins, but if for some reason it must be done
manually follow these steps (this assumes you are using Bash):

1. Download the binary from the nightly build you want to package, place it in
   this directory (the one with the `*.Dockerfile`s).
2. Load the build helpers: `. build_helpers.sh`
3. Build the image: `build_image [dockerfile] [tag] [package file] [path additions]`
  - `[dockerfile]` is the Dockerfile used to build the image, it should be one
      from this directory
  - `[tag]` is the tag to apply to the image, this should follow the format
      described in the section above
  - `[package file]` is the filename of the package you downloaded in step 1
  - `[path additions]` is a list of paths to add to the `PATH` environment
    variable, this should be set according to the target OS and nightly type

The `jenkins_build_nightly.sh` script can be inspected to see how this should
work automatically, this should be enough to give you some hints if anything is
unclear.
