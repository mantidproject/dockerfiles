# Base
ARG DEVELOPMENT_IMAGE_VERSION=0.1
FROM ghcr.io/mantidproject/mantid-development-alma9:${DEVELOPMENT_IMAGE_VERSION}

# set the github runner version
ARG RUNNER_VERSION="2.321.0"

# Add label for transparency.
# "org.opencontainers.image.source" is a standard key for pointing to the source used to build this docker image.
LABEL org.opencontainers.image.source=https://github.com/mantidproject/dockerfiles

# update the base packages and add a non-sudo user
RUN useradd -m docker

# Add target user
# Do we need this?
# RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

RUN dnf -y install jq

# Create source, build and external data directories.
RUN mkdir -p /mantid_src && \
  mkdir -p /mantid_build && \
  mkdir -p /mantid_data

# Fixes "D-Bus library appears to be incorrectly set up;" error
# Do we still need this?
#RUN dbus-uuidgen > /var/lib/dbus/machine-id 

# Download and extract the github actions runner package
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh
# make the script executable
RUN chmod +rx start.sh

USER docker

ENV USER=docker

ENTRYPOINT ["./start.sh"]
