FROM jenkins/inbound-agent:latest-jdk11

# Install extra tools
ENV DEBIAN_FRONTEND=noninteractive
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create jenkins working directory
RUN mkdir -p /jenkins_workdir && \
    chmod o+rw /jenkins_workdir

# Switch back to Jenkins user
USER jenkins
ENTRYPOINT [ "/usr/local/bin/jenkins-agent" ]
