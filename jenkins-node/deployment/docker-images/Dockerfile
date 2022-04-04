FROM python:3.10

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    openjdk-11-jdk \
    ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY ./requirements.txt /tmp/requirements.txt
RUN python -m pip install -r /tmp/requirements.txt

# Setup Jenkins slave
ARG JENKINS_AGENT_VERSION=3.9
RUN mkdir -p /jenkins_workdir && \
    chmod o+rw /jenkins_workdir && \
    curl \
    --location \
    --create-dirs \
    --output /usr/share/jenkins/agent.jar \
    "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_AGENT_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar" && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/agent.jar

ENV AGENT_WORKDIR=/jenkins_workdir
COPY jenkins_agent /usr/share/jenkins/agent.sh

VOLUME ["/jenkins_workdir"]

# Run Jenkins agent script
CMD ["/usr/share/jenkins/agent.sh"]
