# syntax=docker/dockerfile:1

ARG COVERITY_VERSION=latest
ARG ALMALINUX_VERSION=latest

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

FROM ghcr.io/mantidproject/mantid-development-alma:9.6 AS mantid_dev

COPY --from=coverity /cov-analysis-linux64-*.tar.gz /mantid_data/.

# ----

#FROM almalinux:9 AS sns_runner

#LABEL org.opencontainers.image.description



