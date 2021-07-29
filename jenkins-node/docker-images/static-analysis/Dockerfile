#######
# cppcheck build
######

FROM alpine:latest AS cppcheck_build

# Version 1.82
ARG cppcheck_commit=23b253e9eb3296a03afd5d52908726da1231f0dd

RUN apk add git ninja cmake g++ pcre-dev && \
    git clone https://github.com/danmar/cppcheck.git

WORKDIR /cppcheck
RUN git checkout ${cppcheck_commit} && mkdir build

WORKDIR /cppcheck/build
RUN CXXFLAGS="--static" cmake .. -DCMAKE_BUILD_TYPE=Release -DHAVE_RULES=ON \
    -DUSE_MATCHCOMPILER=ON -G Ninja && \
    cmake --build .

FROM mantidproject/jenkins-node:ubuntubionic

ARG FLAKE_VERSION=3.7.9
ARG PEP_VERSION=1.7.1

COPY --from=cppcheck_build /cppcheck/build/bin/cppcheck /usr/local/bin/
COPY --from=cppcheck_build /cppcheck/cfg /usr/local/share/CppCheck
COPY --from=cppcheck_build /cppcheck/htmlreport /tmp/cppcheck-htmlreport

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    clang-format-6.0 \
    doxygen \
    parallel \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install \
    flake8==${FLAKE_VERSION} \
    pep8==${PEP_VERSION}

RUN cd /tmp/cppcheck-htmlreport && python3 setup.py install
