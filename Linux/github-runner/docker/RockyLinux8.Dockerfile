# Base
# rockylinux 8 matches platform used by IDAaaS
FROM rockylinux:8

# set the github runner version
ARG RUNNER_VERSION="2.321.0"

# Install IUS repo for additional yum installs (e.g. git v2 onwards)
# Install EPEL repo as IUS repo has some dependencies on it
# RUN yum install -y \
#   https://repo.ius.io/ius-release-el7.rpm && \
#   yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Add label for transparency.
# "org.opencontainers.image.source" is a standard key for pointing to the source used to build this docker image.
LABEL org.opencontainers.image.source=https://github.com/mantidproject/dockerfiles

# update the base packages and add a non-sudo user
RUN useradd -m docker

# Add target user
# Do we need this?
# RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

# Install minimal developer tools
RUN yum install -y \
  curl \
  gcc \
  git \
  graphviz \
  libXScrnSaver \
  jq \
  make \
  pciutils-libs \
  perl-Digest-MD5 \
  perl-IPC-Cmd \
  sudo \
  wget \
  which \
  xorg-x11-server-Xvfb && \
  # Clean up
  rm -rf /tmp/* /var/tmp/* 

# Install Python - required for publish-unit-test-result-action
RUN dnf install python3.12 -y

# Install patched version of OpenSSL (v3.1.0)
# COPY ./install_openssl.sh /tmp/
# RUN bash /tmp/install_openssl.sh && \
#    rm -rf /OpenSSL

# Latex install currently not working.
# # Install latex
# COPY ./install_latex.sh /tmp/
# RUN bash /tmp/install_latex.sh && \
#    rm -rf /latex
#
# # Set paths for latex here and not in install_latex.sh to allow installation of anyfontsize
# ENV PATH=/usr/local/texlive/2023/bin/x86_64-linux:$PATH
# ENV MANPATH=$MANPATH:/usr/local/texlive/2023/texmf-dist/doc/man
# ENV INFOPATH=$INFOPATH:/usr/local/texlive/2023/texmf-dist/doc/info
#
# # install anyfontsize package
# RUN tlmgr install anyfontsize

# Create source, build and external data directories.
RUN mkdir -p /mantid_src && \
  mkdir -p /mantid_build && \
  mkdir -p /mantid_data

# Fixes "D-Bus library appears to be incorrectly set up;" error
# Do we still need this?
RUN dbus-uuidgen > /var/lib/dbus/machine-id 

# Download and extract the github actions runner package
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh
# make the script executable
RUN chmod +x start.sh

USER docker

ENV USER=docker

ENTRYPOINT ["./start.sh"]
