# Arguments allowed to be used in FROM have to come
# before the first stage
ARG CPPCHECK_VERSION=2.5

# Import cppcheck. COPY --from cannot used variables.
# Define a local name
FROM neszt/cppcheck-docker:${CPPCHECK_VERSION} AS upstream_cppcheck

# Base
FROM centos:7

# Add target user
RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

# Install minimal developer tools
RUN yum install -y \
  ccache \
  curl \
  git \
  graphviz \
  libXScrnSaver \
  pciutils-libs \
  python36-pip \
  sudo \
  texlive-latex \
  texlive-latex-bin \
  texlive-was \
  tex-preview \
  which \
  xorg-x11-server-Xvfb && \
  # Install pre-commit
  python3 -m pip install pre-commit && \
  # Clean up
  rm -rf /tmp/* /var/tmp/*

# Copy in cppcheck
COPY --from=upstream_cppcheck /usr/bin/cppcheck /usr/local/bin/
COPY --from=upstream_cppcheck /usr/bin/cppcheck-htmlreport /usr/local/bin/
COPY --from=upstream_cppcheck /cfg/ /cfg/
# Fix-up for Python3
RUN sed -e '1 s@python@python3@' -i /usr/local/bin/cppcheck-htmlreport

# Create source, build, and external data directories.
RUN mkdir -p /mantid_src && \
  mkdir -p /mantid_build && \
  mkdir -p /mantid_data && \
  mkdir -p /ccache

# Set ccache cache location
ENV CCACHE_DIR /ccache

# Allow mounting source, build, data and ccache directories
VOLUME ["/mantid_src", "/mantid_build", "/mantid_data", "/ccache"]

# Set default working directory to build directory
WORKDIR /mantid_build

# Fixes "D-Bus library appears to be incorrectly set up;" error
RUN dbus-uuidgen > /var/lib/dbus/machine-id

# Run as abc user on starting the container
ADD entrypoint.sh /entrypoint.sh
ADD entrypoint.d/ /etc/entrypoint.d/
ENTRYPOINT ["/entrypoint.sh"]
