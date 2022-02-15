# Arguments allowed to be used in FROM have to come
# before the first stage
ARG CPPCHECK_VERSION=2.7

# Import cppcheck. COPY --from cannot used variables.
# Define a local name
FROM neszt/cppcheck-docker:${CPPCHECK_VERSION} AS upstream_cppcheck

# Base
FROM centos:7

ARG DEV_PACKAGE_VERSION
ARG FLAKE_VERSION=3.7.9
ARG PEP_VERSION=1.7.1

# Add target user
RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
  yum install -y \
  centos-release-scl \
  yum-plugin-copr \
  sudo && \
  # Add Mantid repository, install developer package and GCC 7
  yum copr enable -y mantid/mantid && \
  yum install -y mantid-developer-${DEV_PACKAGE_VERSION} devtoolset-7-gcc-c++ && \
  # Install ccache
  yum install -y \
  ccache && \
  # Install xvfb
  yum install -y \
  xorg-x11-server-Xvfb && \
  # Install jemalloc
  yum install -y \
  jemalloc-devel && \
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

# Install versions of Python static analysis tools
RUN pip3 install \
  flake8==${FLAKE_VERSION} \
  pep8==${PEP_VERSION}

# Create source, build, and external data directories.
RUN mkdir -p /mantid_src && \
  mkdir -p /mantid_build && \
  mkdir -p /mantid_data && \
  mkdir -p /ccache

# Set ccache cache location
ENV CCACHE_DIR /ccache

# Allow mounting source, build, data and ccache directories
VOLUME ["/mantid_src", "/mantid_build", "/mantid_data", "/ccache"]

# Allow passwordless sudo access for abc user
ADD abc_sudo_with_no_passwd \
  /etc/sudoers.d/abc_sudo_with_no_passwd

# Set default working directory to build directory
WORKDIR /mantid_build

# Add default CMake configure helper script
ADD configure/centos7.sh \
  /home/abc/configure.sh
RUN chown abc:abc /home/abc/configure.sh

# Fixes "D-Bus library appears to be incorrectly set up;" error
RUN dbus-uuidgen > /var/lib/dbus/machine-id

ADD entrypoint.sh /entrypoint.sh
ADD entrypoint.d/ /etc/entrypoint.d/
ENTRYPOINT ["/entrypoint.sh"]
