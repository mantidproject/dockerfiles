FROM ubuntu:bionic

ARG DEV_PACKAGE_VERSION
ARG PARAVIEW_BUILD_REVISION

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
    # Install ccache
    apt-get install -y \
      ccache && \
    # Install xvfb
    apt-get install -y \
      xvfb && \
    # Install debugging tools
    apt-get install -y \
      gdb && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create build and external data directories
RUN mkdir -p /mantid_src && \
    mkdir -p /mantid_build && \
    mkdir -p /mantid_data && \
    mkdir -p /ccache && \
    mkdir -p /paraview

# Build ParaView
RUN git clone https://github.com/mantidproject/paraview-build.git /tmp/paraview && \
    git -C /tmp/paraview checkout ${PARAVIEW_BUILD_REVISION} && \
    env HOME=/paraview BUILD_THREADS=`nproc` NODE_LABELS=ubuntu JOB_NAME=python3 /tmp/paraview/buildscript && \
    # Give world RW access to ParaView
    chmod -R o+rw /paraview && \
    # Clean up
    rm -rf /tmp/* /var/tmp/*

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
