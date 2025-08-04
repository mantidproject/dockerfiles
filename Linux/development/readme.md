# Mantid development environment in Docker for Linux

Docker container for building, testing and developing Mantid in Linux. If your host system is Windows then it might be better to setup a [Windows Subsystem for Linux (WSL2)](https://developer.mantidproject.org/WindowsSubsystemForLinux.html).

## Base images and versions

The current base image is:

- [`mantid-development-alma9`](https://github.com/mantidproject/dockerfiles/pkgs/container/mantid-development-alma9) - Alma 9

Typically you'd want to use the `latest` tag, this corresponds to the latest version of the developer package.

## Jenkins image

A separate image is available for the Jenkins set up of a Linux node:

- [`jenkins-node-alma9`](https://github.com/mantidproject/dockerfiles/pkgs/container/jenkins-node-alma9) 

As with the base image you typically want to use the `latest` tag.

## Updating images

For changes to the main image update the [`Alma9.Dockerfile`](https://github.com/mantidproject/dockerfiles/tree/main/Linux/development/docker). You will also need to update the `build_common.sh` file in the same folder with an updated version number. 

If you make changes to the main file you will also need to update the Jenkins image as this specifies which version of the base image you want to use. This file is also called [`Alma9.Dockerfile`](https://github.com/mantidproject/dockerfiles/tree/main/Linux/jenkins-node/docker) but is located within the jenkins-node subfolders. As with the base image you will also need to update the `build_common.sh` file in the same folder with an updated version number.

## Building locally

On Linux an easy way to build a docker container from the image is to run the `build.sh` file from the same folder as the image you want to build.

To build the jenkins-node docker container run `DOCKER_BUILDKIT=1 ./build.sh` from the folder the file is located in.

## Publishing updated images

All our images are hosted on GitHub instead of Docker. In order to publish new images to GitHub you will need to do the following

- run the `build.sh` file to ensure the new image builds without issue
- generate a new GitHub token that will give you read and write access to Mantid project
- Ensure you have your conda environment active and that docker is available (run the command ```docker run hello-world``` to check this)
- set up your GitHub token using the following as a guide. Be sure to use your own GitHub user name.
```
GH_TOKEN=XXXXXXXXXXXXXXXX
echo "$GH_TOKEN" | docker login ghcr.io -u YourGitHubUserName --password-stdin
```
- run the `push.sh` file
- Check the page for the image pushed to check that it has uploaded as expected. This page can be accessed from the [`Mantid Packages page`](https://github.com/orgs/mantidproject/packages)
- If you have pushed the base image you will also need to push the Jenkins image
- Once you are happy that the new image works as expected delete any older versions. At any one time we will only have the current and one previous image available.

## Using images
See [`Ansible readme`](https://github.com/mantidproject/dockerfiles/blob/main/Linux/jenkins-node/ansible/readme.md) for details of using ansible scripts to set up nodes using these Linux docker images.

