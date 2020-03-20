#######
# cppcheck build
######

FROM alpine:latest AS cppcheck_build

# Version 1.90
ARG cppcheck_commit=077e652

RUN apk add git ninja cmake g++ pcre-dev && \
    git clone https://github.com/danmar/cppcheck.git

WORKDIR /cppcheck
RUN git checkout ${cppcheck_commit} && mkdir build

WORKDIR /cppcheck/build
RUN CXXFLAGS="--static" cmake .. -DCMAKE_BUILD_TYPE=Release -DHAVE_RULES=ON \
    -DUSE_MATCHCOMPILER=ON -G Ninja && \
    cmake --build .

FROM jenkins/jnlp-slave

ARG FLAKE_VERSION=3.7.9
ARG PEP_VERSION=1.7.1

COPY --from=cppcheck_build /cppcheck/build/bin/cppcheck /usr/bin/
COPY --from=cppcheck_build /cppcheck/cfg /usr/local/share/Cppcheck/cfg

USER root

RUN apt-get update
RUN apt-get install -t stretch-backports cmake -y --no-install-recommends

# Ordered in probability of each updating from least->most
RUN apt-get install clang-format-6.0 parallel -y --no-install-recommends
RUN apt-get install cmake -y --no-install-recommends
RUN apt-get install doxygen -y --no-install-recommends
RUN apt-get install python3 python3-pip -y --no-install-recommends

RUN pip3 install \
    flake8==${FLAKE_VERSION} \
    pep8==${PEP_VERSION}

USER jenkins
