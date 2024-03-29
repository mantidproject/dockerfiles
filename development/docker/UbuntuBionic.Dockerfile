# Arguments allowed to be used in FROM have to come
# before the first stage
ARG CPPCHECK_VERSION=2.5

# Import cppcheck. COPY --from cannot used variables.
# Define a local name
FROM neszt/cppcheck-docker:${CPPCHECK_VERSION} AS upstream_cppcheck

# Base
FROM ubuntu:bionic

ARG DEV_PACKAGE_VERSION
ARG FLAKE_VERSION=3.7.9
ARG PEP_VERSION=1.7.1

# Needed to allow install of tzdata
ENV DEBIAN_FRONTEND noninteractive

# Add target user
RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

RUN apt-get update && \
    # Install prerequisite tools
    apt-get install -y \
      apt-transport-https \
      gdebi-core\
      git \
      python-pip \
      software-properties-common \
      sudo \
      wget && \
    # Add Kitware's repository
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add - && \
    apt-add-repository -y "deb https://apt.kitware.com/ubuntu/ $(lsb_release -c | cut -f 2) main" && \
    # Add Mantid repository
    wget -O - http://apt.isis.rl.ac.uk/2E10C193726B7213.asc 2>/dev/null | apt-key add - && \
    apt-add-repository -y "deb [arch=amd64] http://apt.isis.rl.ac.uk $(lsb_release -c | cut -f 2) main" && \
    apt-add-repository -y ppa:mantid/mantid && \
    # Install the Mantid developer package
    apt-get update && \
    wget -O /tmp/mantid-developer.deb https://downloads.sourceforge.net/project/mantid/developer/mantid-developer_${DEV_PACKAGE_VERSION}_all.deb && \
    gdebi --non-interactive /tmp/mantid-developer.deb && \
    # Set qt5 by default
    apt-get install -y \ 
      qt5-default && \
    # Install ccache
    apt-get install -y \
      ccache && \
    # Install xvfb
    apt-get install -y \
      xvfb && \
    # Install jemalloc
    apt-get install -y \
      libjemalloc-dev && \
    # Install libpci for tests in a conda env
    apt-get install -y libpci-dev && \
    # Install debugging tools
    apt-get install -y \
      gdb && \
    # Install pre-commit
    python3 -m pip install pre-commit && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

# Create build and external data directories
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
ADD configure/ubuntu.sh \
    /home/abc/configure.sh
RUN chown abc:abc /home/abc/configure.sh

ADD entrypoint.sh /entrypoint.sh
ADD entrypoint.d/ /etc/entrypoint.d/
ENTRYPOINT ["/entrypoint.sh"]
