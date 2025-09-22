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

FROM latex_direct AS fslayout

# Allow mounting source, build and data directories
VOLUME ["/mantid_src", "/mantid_build", "/mantid_data"]

# Set default working directory to build directory
WORKDIR /mantid_build

# ----


FROM fslayout AS mantid_development

COPY --chmod=755 <<-__EOF__ /entrypoint.sh
	#!/bin/bash
	
	# Handles setting up the target user (abc) and redirecting the command to be
	# executed by them.
	# This is all in aid of ensuring that permissions of filesystem mapped volumes
	# function correctly and that the root user is not used within the container.
	
	
	000_change_user_ids() {
	
	  PUID=\${PUID:-911}
	  PGID=\${PGID:-911}
	
	  # Set target user's IDs to match that of the "external"/"host" user
	  groupmod --non-unique --gid \${PGID} \${TARGET_USERNAME}
	  usermod  --non-unique --uid \${PUID} \${TARGET_USERNAME}
	}
	
	
	010_abc_own_directories() {
	
	# Take ownership of working directories
	  chown \${TARGET_USERNAME}:\${TARGET_USERNAME} /mantid_src
	  chown \${TARGET_USERNAME}:\${TARGET_USERNAME} /mantid_build
	  chown \${TARGET_USERNAME}:\${TARGET_USERNAME} /mantid_data
	}
	
	020_locale() {
	
	  export LANG=C.UTF-8
	}
	
	# enable xtrace
	set -x
	
	TARGET_USERNAME="abc"
	
	# Execute entrypoint rules
	000_change_user_ids
	010_abc_own_directories
	020_locale
	
	# Run the supplied command as the target user
	CMD=\${@:-"bash"}
	# This form of runuser is used as it only sets the environment variables
	# required to change the user, preserving all others that are set (see man
	# runuser).
	runuser -u \${TARGET_USERNAME} -- \${CMD}
	
__EOF__

ENTRYPOINT ["/entrypoint.sh"]


# ----

FROM mantid_development AS jenkins_node

# Install Java
RUN dnf -y install java-17-openjdk-devel
RUN dnf clean all

# Add jenkins agent jar
ARG JENKINS_AGENT_VERSION=3327.v868139a_d00e0
ARG JENKINS_AGENT_SHA256=539da6810936b7df54e204ce7a0257ad2a1b88c620b8a19c74a980ceb1ac5c9d
ADD \
    --checksum=${JENKINS_AGENT_SHA256} \
    --chmod=644 \
  https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_AGENT_VERSION}/remoting-${JENKINS_AGENT_VERSION}.jar
  /usr/share/jenkins/agent.jar

RUN echo 'export DOCKER_BUILDKIT=1' >> ${HOME}/.profile

# Define the working directory of the agent
ENV AGENT_WORKDIR=/jenkins_workdir

# Allow mounting as a volume
VOLUME ["/jenkins_workdir"]

COPY --chmod=755 jenkins-node/jenkins_agent /usr/share/jenkins/agent.sh

CMD ["/usr/share/jenkins/agent.sh"]



# ----



#FROM almalinux:latest
#COPY --from=0 /etc/os-release /tmp/base-os-release





