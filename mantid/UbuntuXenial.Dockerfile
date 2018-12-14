FROM ubuntu:xenial

ARG PACKAGE
ARG PATH_ADDITIONS

ADD ${PACKAGE} /tmp/mantid.deb

RUN apt-get update && \
    apt-get install -y \
      curl \
      gdebi \
      software-properties-common gdebi && \
    curl http://apt.isis.rl.ac.uk/2E10C193726B7213.asc | apt-key add - && \
    apt-add-repository -y "deb [arch=amd64] http://apt.isis.rl.ac.uk $(lsb_release -c | cut -f 2)-testing main" && \
    apt-add-repository -y ppa:mantid/mantid && \
    apt-get update && \
    gdebi --non-interactive /tmp/mantid.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH=${PATH_ADDITIONS}:${PATH}
