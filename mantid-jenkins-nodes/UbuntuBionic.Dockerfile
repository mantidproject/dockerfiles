FROM mantidproject/mantid-development-ubuntubionic:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      openjdk-8-jdk \
      xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV DISPLAY=:39

# Setup Jenkins slave
ARG JENKINS_SLAVE_VERSION=3.9
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/slave.jar
ENV AGENT_WORKDIR=${HOME}
COPY jenkins_slave /usr/share/jenkins/slave.sh

# Set volume for AGENT_WORKDIR
VOLUME ["/root"]

# Run Jenkins slave script
CMD ["/usr/share/jenkins/slave.sh"]
