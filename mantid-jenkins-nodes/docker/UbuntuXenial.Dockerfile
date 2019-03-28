FROM mantidproject/mantid-development-ubuntuxenial:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      gdebi-core \
      openjdk-8-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup Jenkins slave
ARG JENKINS_SLAVE_VERSION=3.9
RUN mkdir -p /jenkins_workdir && \
    chmod o+rw /jenkins_workdir && \
    curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/slave.jar && \
    # Remove passwordless sudo for CI runner
    rm /etc/sudoers.d/abc_sudo_with_no_passwd
ENV AGENT_WORKDIR=/jenkins_workdir
COPY jenkins_slave /usr/share/jenkins/slave.sh

# Add passwordless access required for systemtests
ADD abc_systemtests_sudoer_ubuntu \
    /etc/sudoers.d/abc_systemtests_sudoer_ubuntu

VOLUME ["/jenkins_workdir"]

# Run Jenkins slave script
CMD ["/usr/share/jenkins/slave.sh"]
