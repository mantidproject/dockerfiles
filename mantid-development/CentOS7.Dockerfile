FROM centos:7

ARG DEV_PACKAGE_VERSION
ARG PARAVIEW_BUILD_REVISION

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y yum-plugin-copr centos-release-scl && \
    # Add Mantid repository, install developer package and GCC 7
    yum copr enable -y mantid/mantid && \
    yum install -y mantid-developer-${DEV_PACKAGE_VERSION} devtoolset-7-gcc-c++ && \
    # Install static analysis dependencies
    pip install \
      flake8==2.5.4 \
      pep8==1.6.2 \
      pyflakes==1.3.0 \
      mccabe==0.6.1 && \
    # Build ParaView
    git clone https://github.com/mantidproject/paraview-build.git /tmp/paraview && \
    git --git-dir=/tmp/paraview/.git --work-tree=/tmp/paraview checkout ${PARAVIEW_BUILD_REVISION} && \
    env BUILD_THREADS=`nproc` NODE_LABELS=centos7 /tmp/paraview/buildscript /paraview_build && \
    # Clean up
    rm -rf /tmp/* /var/tmp/*

# Create source, build and external data directories
RUN mkdir -p /mantid_src && \
    mkdir -p /mantid_build && \
    mkdir -p /mantid_data

# Allow mounting source, build and data directories
VOLUME ["/mantid_src", "/mantid_build", "/mantid_data"]

# Set default working directory to build directory
WORKDIR /mantid_build
