FROM centos:7

ARG DEV_PACKAGE_VERSION
ARG PARAVIEW_BUILD_REVISION

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
    # Install static analysis dependencies
    pip install \
      flake8==2.5.4 \
      pep8==1.6.2 \
      pyflakes==1.3.0 \
      mccabe==0.6.1 && \
    # Clean up
    rm -rf /tmp/* /var/tmp/*

# Create source, build, external data and ParaView directories
RUN mkdir -p /mantid_src && \
    mkdir -p /mantid_build && \
    mkdir -p /mantid_data && \
    mkdir -p /ccache && \
    mkdir -p /paraview

# Build ParaView
RUN git clone https://github.com/mantidproject/paraview-build.git /tmp/paraview && \
    git --git-dir=/tmp/paraview/.git --work-tree=/tmp/paraview checkout ${PARAVIEW_BUILD_REVISION} && \
    env HOME=/paraview BUILD_THREADS=`nproc` NODE_LABELS=centos7 /tmp/paraview/buildscript && \
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
