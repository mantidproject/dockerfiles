# syntax=docker/dockerfile:1

# ----
FROM ghcr.io/mantidproject/cov-analysis-linux64:latest AS coverity




#FROM ghcr.io/mantidproject/mantid-development-alma:9.6 AS mantid_dev
#FROM ghcr.io/mantidproject/github-actions-alma:9.6 AS github_runner

FROM ghcr.io/mantidproject/mantid-development-alma:9.6 AS github_runner_coverity

COPY --from=coverity /cov-analysis-linux64-*.tar.gz /mantid_data/.

