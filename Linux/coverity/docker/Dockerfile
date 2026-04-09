# syntax=docker/dockerfile:1

ARG REPO=mantidproject/cov-analysis-linux64

FROM alpine:latest as prelude
RUN --mount=type=secret,id=GITHUB_TOKEN,env=GITHUB_TOKEN \
  read -r EPHEMERAL_TOKEN <<< $(
    curl -s -u "x-access-token:${GITHUB_TOKEN}" "https://ghcr.io/token?service=ghcr.io&scope=repository:${REPO}:pull" \
      | jq -r '.token'
  )
  echo ${EPHEMERAL_TOKEN} | cut -c 8-

# ----
#FROM ghcr.io/mantidproject/cov-analysis-linux64:latest AS coverity
#FROM ghcr.io/mantidproject/mantid-development-alma:9.6 AS mantid_dev

# ----
#FROM almalinux:9 AS sns_runner

#LABEL org.opencontainers.image.description

#COPY --from=coverity /cov-analysis-linux64-*.tar.gz /mantid_data/.

