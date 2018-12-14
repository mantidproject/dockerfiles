FROM centos:7

ARG PACKAGE
ARG PATH_ADDITIONS

ADD ${PACKAGE} /tmp/mantid.rpm

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y yum-plugin-copr && \
    yum copr enable -y mantid/mantid && \
    yum localinstall -y /tmp/mantid.rpm && \
    rm -rf /tmp/*

ENV PATH=${PATH_ADDITIONS}:${PATH}
