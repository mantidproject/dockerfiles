# Arguments allowed to be used in FROM have to come
# before the first stage
ARG DEVELOPMENT_IMAGE_VERSION=0.1
FROM ghcr.io/mantidproject/mantid-development-alma9:${DEVELOPMENT_IMAGE_VERSION}

#Add label for transparency
LABEL org.opencontainers.image.source https://github.com/mantidproject/dockerfiles

# Install dependencies
RUN yum install -y \
  java-17-openjdk-devel && \
  rm -rf /tmp/* /var/tmp/*

# Setup Jenkins agent
ARG JENKINS_AGENT_VERSION=4.14
RUN export DOCKER_BUILDKIT=1 && \
  mkdir -p /jenkins_workdir && \
  chmod o+rw /jenkins_workdir && \
  curl \
  --location \
  --create-dirs \
  --output /usr/share/jenkins/agent.jar \
  "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_AGENT_VERSION}/remoting-${JENKINS_AGENT_VERSION}.jar" && \
  chmod 755 /usr/share/jenkins && \
  chmod 644 /usr/share/jenkins/agent.jar
  
RUN echo 'export DOCKER_BUILDKIT=1' >> $HOME/.profile

# Define the working directory of the agent
ENV AGENT_WORKDIR=/jenkins_workdir

# Startup script to run on container launch
COPY --chmod=755 jenkins_agent /usr/share/jenkins/agent.sh

# Allow mounting as a volume
VOLUME ["/jenkins_workdir"]

# Set ownership and launch
ADD entrypoint.d/* /etc/entrypoint.d/
CMD ["/usr/share/jenkins/agent.sh"]
