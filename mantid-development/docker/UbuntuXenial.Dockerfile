FROM ubuntu:xenial

ARG DEV_PACKAGE_VERSION
ARG PARAVIEW_BUILD_REVISION

# Add target user
RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

RUN apt-get update && \
    # Install prerequisite tools
    apt-get install -y \
      software-properties-common \
      wget \
      gdebi-core \
      python-pip \
      sudo && \
    # Add Mantid repository and install the developer package
    wget -O - http://apt.isis.rl.ac.uk/2E10C193726B7213.asc | apt-key add - && \
    apt-add-repository -y "deb [arch=amd64] http://apt.isis.rl.ac.uk $(lsb_release -c | cut -f 2) main" && \
    apt-add-repository -y ppa:mantid/mantid && \
    apt-get update && \
    wget -O /tmp/mantid-developer.deb https://downloads.sourceforge.net/project/mantid/developer/mantid-developer_${DEV_PACKAGE_VERSION}_all.deb && \
    gdebi --non-interactive /tmp/mantid-developer.deb && \
    # Install ccache
    apt-get install -y \
      ccache && \
    # Install Python 3 dependencies (see http://developer.mantidproject.org/Python3.html)
    apt-get install -y \
      python3-sip-dev \
      python3-pyqt4 \
      python3-numpy \
      python3-scipy \
      python3-sphinx \
      python3-sphinx-bootstrap-theme \
      python3-dateutil \
      python3-matplotlib \
      ipython3-qtconsole \
      python3-h5py \
      python3-yaml && \
    # Install static analysis dependencies
    pip install \
      flake8==2.5.4 \
      pep8==1.6.2 \
      pyflakes==1.3.0 \
      mccabe==0.6.1 && \
    apt-get install -y \
      cppcheck && \
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
    env HOME=/paraview BUILD_THREADS=`nproc` NODE_LABELS=ubuntu /tmp/paraview/buildscript && \
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

# Add a symlink pointing the default external data location to the mapped
# volume
RUN ln -s \
      /mantid_data \
      /home/abc/MantidExternalData

# Set default working directory to build directory
WORKDIR /mantid_build

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
