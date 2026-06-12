# syntax=docker/dockerfile:1

# Globally scoped ARGs
ARG ALMALINUX_VERSION=9
ARG COVERITY_VERSION

# ----

FROM ghcr.io/mantidproject/cov-analysis-linux64:${COVERITY_VERSION} AS coverity
#LABEL org.opencontainers.image.description Coverity Scan Build Tool version ${tag}

#
# cov-analysis-linux64 is a scratch container image with just the coverity tarball
#

# ----

FROM almalinux:${ALMALINUX_VERSION} AS mantid_dev
RUN dnf -y install \
      file gcc git make jq sudo wget which \
      libXScrnSaver xorg-x11-server-Xvfb \
      graphviz pciutils-libs

# ----

FROM mantid_dev AS gha_runner
# Bring a global ARGs into this stage's scope
ARG GHA_RUNNER_DOWNLOAD
ARG GHA_RUNNER_VERSION

RUN useradd -m docker --create-home
RUN mkdir /mantid_data
RUN chown docker:docker /mantid_data
RUN chmod 755 /mantid_data

# Switch to docker user
USER docker

# Unpack github actions runner
ADD --chown=docker:docker \
    ${GHA_RUNNER_DOWNLOAD} /home/docker/actions-runner/
RUN \
     cd /home/docker/actions-runner \
  && tar xzf ./actions-runner-linux-x64-*.tar.gz \
  && rm -f   ./actions-runner-linux-x64-*.tar.gz

# Switch to root user
USER root

# Install required dependencies for github actions self-hosted runner
RUN /home/docker/actions-runner/bin/installdependencies.sh
#
# The script bin/installdependencies.sh is a utility provided with the
# GitHub Actions self-hosted runner to automate the installation of
# required system-level dependencies on Linux-based systems. 
#
#

# Switch back to docker user
USER docker

# ----

FROM gha_runner AS final

# Bring a global ARG into this stage's scope
ARG COVERITY_VERSION

COPY --from=coverity /cov-analysis-linux64-*.tar.gz /mantid_data/.
RUN \
     cd /mantid_data \
  && tar xzf ./cov-analysis-linux64-*.tar.gz \
  && rm -f   ./cov-analysis-linux64-*.tar.gz

ADD --chmod=755 mantid_testdata_preload.sh /usr/local/bin

ENV COVERITY_DIR=/mantid_data/cov-analysis-linux64-${COVERITY_VERSION}/bin



