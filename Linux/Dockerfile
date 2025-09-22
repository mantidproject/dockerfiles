# syntax=docker/dockerfile:1.6

ARG SEMVER_TAG

FROM almalinux:${SEMVER_TAG} AS os_pkgs

# Add target user
RUN useradd --uid 911 --user-group --shell /bin/bash --create-home abc

# Install developer tools
RUN dnf -y install \
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
  xorg-x11-server-Xvfb

RUN dnf clean all

# ----

FROM os_pkgs AS latex_direct

# Install latex direct from texlive
RUN  mkdir -p /latex \
  && cd /latex \
  && curl https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O -L \
  && zcat install-tl-unx.tar.gz | tar xf - \
  && cd install-tl-2* \
  && perl ./install-tl --scheme=medium --no-interaction

# set paths to enable texlive pkg manager
ENV PATH=/usr/local/texlive/2025/bin/x86_64-linux:$PATH
ENV MANPATH=$MANPATH:/usr/local/texlive/2025/texmf-dist/doc/man
ENV INFOPATH=$INFOPATH:/usr/local/texlive/2025/texmf-dist/doc/info

# Install anyfontsize using texlive pkg manager
RUN tlmgr install anyfontsize

# ----





#FROM almalinux:latest
#COPY --from=0 /etc/os-release /tmp/base-os-release





