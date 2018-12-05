FROM ubuntu:bionic

ARG DEV_PACKAGE_VERSION
ARG PARAVIEW_BUILD_REVISION

# Needed to allow install of tzdata
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    # Install prerequisite tools
    apt-get install -y \
      gdebi-core\
      git \
      python-pip \
      software-properties-common \
      wget && \
    # Add Mantid PPA repository and install the developer package
    wget -O - http://apt.isis.rl.ac.uk/2E10C193726B7213.asc | apt-key add - && \
    apt-add-repository -y "deb [arch=amd64] http://apt.isis.rl.ac.uk $(lsb_release -c | cut -f 2) main" && \
    apt-add-repository -y ppa:mantid/mantid && \
    apt-get update && \
    wget -O /tmp/mantid-developer.deb https://downloads.sourceforge.net/project/mantid/developer/mantid-developer_${DEV_PACKAGE_VERSION}_all.deb && \
    gdebi --non-interactive /tmp/mantid-developer.deb && \
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
    # Build ParaView
    git clone https://github.com/mantidproject/paraview-build.git /tmp/paraview && \
    git -C /tmp/paraview checkout ${PARAVIEW_BUILD_REVISION} && \
    env BUILD_THREADS=`nproc` NODE_LABELS=ubuntu /tmp/paraview/buildscript /paraview_build && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create build and external data directories
RUN mkdir -p /mantid_src && \
    mkdir -p /mantid_build && \
    mkdir -p /mantid_data

# Allow mounting source, build and data directories
VOLUME ["/mantid_src", "/mantid_build", "/mantid_data"]

# Set default working directory to build directory
WORKDIR /mantid_build
