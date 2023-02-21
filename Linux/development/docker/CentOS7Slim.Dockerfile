# Arguments allowed to be used in FROM have to come
# before the first stage
ARG CPPCHECK_VERSION=2.5

# Import cppcheck. COPY --from cannot used variables.
# Define a local name
FROM neszt/cppcheck-docker:${CPPCHECK_VERSION} AS upstream_cppcheck

#Add label for transparency
LABEL org.opencontainers.image.source https://github.com/mantidproject/dockerfiles

# Base
# CentOS 7 matches platform used by conda-forge
FROM centos:7

# Install IUS repo for additional yum installs (e.g. git v2 onwards)
# Install EPEL repo as IUS repo has some dependencies on it
RUN yum install -y \
  https://repo.ius.io/ius-release-el7.rpm && \
  yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
 
# Add target user
RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

# Install minimal developer tools
RUN yum install -y \
  ccache \
  curl \
  gcc \
  git236 \
  graphviz \
  libXScrnSaver \
  make \
  pciutils-libs \
  perl-Digest-MD5 \
  sudo \
  wget \
  which \
  xorg-x11-server-Xvfb && \
  # Clean up
  rm -rf /tmp/* /var/tmp/* 

  
# Install patched version of OpenSSL (v1.1.1t)
COPY ./install_openssl.sh /tmp/
RUN bash /tmp/install_openssl.sh && \
   rm -rf /OpenSSL

# Install latex
COPY ./install_latex.sh /tmp/
RUN bash /tmp/install_latex.sh && \
   rm -rf /latex

# Set paths for latex
ENV PATH=/usr/local/texlive/2022/bin/x86_64-linux:$PATH
ENV MANPATH=$MANPATH:/usr/local/texlive/2022/texmf-dist/doc/man
ENV INFOPATH=$INFOPATH:/usr/local/texlive/2022/texmf-dist/doc/info

# install anyfontsize package
RUN tlmgr install anyfontsize

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
