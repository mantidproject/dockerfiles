# Base

ARG SEMVER_TAG

FROM almalinux:${SEMVER_TAG}

# Add label for transparency
LABEL org.opencontainers.image.source https://github.com/mantidproject/dockerfiles
 
# Add target user
RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

# Install minimal developer tools
RUN yum install -y \
  gcc \
  git\
  graphviz \
  libXScrnSaver \
  make \
  pciutils-libs \
  perl-Digest-MD5 \
  perl-IPC-Cmd \
  sudo \
  wget \
  which \
  xorg-x11-server-Xvfb && \
  # Clean up
  rm -rf /tmp/* /var/tmp/* 

# Install latex
COPY ./install_latex.sh /tmp/
RUN bash /tmp/install_latex.sh && \
   rm -rf /latex

# Set paths for latex here and not in install_latex.sh to allow installation of anyfontsize
ENV PATH=/usr/local/texlive/2025/bin/x86_64-linux:$PATH
ENV MANPATH=$MANPATH:/usr/local/texlive/2025/texmf-dist/doc/man
ENV INFOPATH=$INFOPATH:/usr/local/texlive/2025/texmf-dist/doc/info

# install anyfontsize package
RUN tlmgr install anyfontsize

# Create source, build and external data directories.
RUN mkdir -p /mantid_src && \
  mkdir -p /mantid_build && \
  mkdir -p /mantid_data

# Allow mounting source, build and data directories
VOLUME ["/mantid_src", "/mantid_build", "/mantid_data"]

# Set default working directory to build directory
WORKDIR /mantid_build

# Fixes "D-Bus library appears to be incorrectly set up;" error
#RUN dbus-uuidgen > /var/lib/dbus/machine-id 

# Run as abc user on starting the container
ADD entrypoint.sh /entrypoint.sh
ADD entrypoint.d/ /etc/entrypoint.d/
ENTRYPOINT ["/entrypoint.sh"]
