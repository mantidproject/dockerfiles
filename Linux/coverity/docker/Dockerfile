# syntax=docker/dockerfile:1


FROM scratch AS coverity

COPY ./cov-analysis-linux64-*.tar.gz /


#FROM ghcr.io/mantidproject/mantid-development-alma:9.6 AS mantid_dev
#FROM ghcr.io/mantidproject/github-actions-alma:9.6 AS github_runner

FROM ghcr.io/mantidproject/mantid-development-alma:9.6 AS github_runner_coverity

ADD --from=coverity /cov-analysis-linux64-*.tar.gz /mantid_data/.

