# syntax=docker/dockerfile:1

# Globally scoped ARGs
ARG ALMALINUX_VERSION=9
ARG COVERITY_VERSION

# ----

FROM alpine:latest AS prelude
ENV REPO=mantidproject/cov-analysis-linux64
RUN apk add curl jq bash
RUN --mount=type=secret,id=GITHUB_TOKEN,env=GITHUB_TOKEN <<__EOT__ bash
  repository=$REPO
  repository=\${repository##*:}
  read -r bearer_token <<< \$(
    curl -s -u "x-access-token:\${GITHUB_TOKEN}" "https://ghcr.io/token?service=ghcr.io&scope=repository:\${repository}:pull" | jq -r '.token'
  )
  for tag in \$(
        curl \
            -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
            -H "Authorization: Bearer \${bearer_token:-null}" \
            -s \
          "https://ghcr.io/v2/\${repository}/tags/list" \
        | jq -r '.tags[]'
      )
  do
      curl \
          -H "Accept: application/vnd.oci.image.manifest.v1+json" \
          -H "Authorization: Bearer \${bearer_token:-null}" \
          -s \
        "https://ghcr.io/v2/\${repository}/manifests/\${tag}" \
      | jq -r --arg tag "\${tag}" '{tag: \$tag, digest: .config.digest}'
  done \
    | jq -r -s '.
      | group_by(.digest) | .[]
      | select(.[].tag == "latest") | .[]
      | select(.tag != "latest") | .tag
    ' \
  > /coverity-version-latest.txt
__EOT__

# ----

FROM ghcr.io/mantidproject/cov-analysis-linux64:${COVERITY_VERSION} AS coverity
#LABEL org.opencontainers.image.description Coverity Scan Build Tool version ${tag}


# ----

FROM almalinux:${ALMALINUX_VERSION} AS mantid_dev
RUN dnf -y install \
      file gcc git make jq sudo wget which \
      libXScrnSaver xorg-x11-server-Xvfb \
      graphviz pciutils-libs


# ----

FROM mantid_dev AS gha_runner
# Bring a global ARGs into this stage's scope
ARG GHA_RUNNER_DOWNLOAD
ARG GHA_RUNNER_VERSION

RUN useradd -m docker --create-home
RUN mkdir /mantid_data
RUN chown docker:docker /mantid_data
RUN chmod 755 /mantid_data
USER docker

ADD --chown=docker:docker \
    ${GHA_RUNNER_DOWNLOAD} /home/docker/actions-runner/
RUN \
     cd /home/docker/actions-runner \
  && tar xzf ./actions-runner-linux-x64-*.tar.gz \
  && rm -f   ./actions-runner-linux-x64-*.tar.gz


# ----

FROM gha_runner AS sns_runner
# Bring a global ARG into this stage's scope
ARG COVERITY_VERSION

COPY --from=coverity /cov-analysis-linux64-*.tar.gz /mantid_data/.
RUN \
     cd /mantid_data \
  && tar xzf ./cov-analysis-linux64-*.tar.gz \
  && rm -f   ./cov-analysis-linux64-*.tar.gz

ADD --chmod=755 mantid_testdata_preload.sh /usr/local/bin

ENV COVERITY_DIR=/mantid_data/cov-analysis-linux64-${COVERITY_VERSION}/bin
#LABEL org.opencontainers.image.description



