#!/bin/bash

_almalinux_version_latest() {

  # retrieve equivalent semantic version (x.y) of almalinux image latest tag

  if version_latest=$(../../../utils/equate_tag_semver "docker.io/library/almalinux:9")
  then
    echo '{}' \
      | jq -r \
        --compact-output \
        --arg version_latest "${version_latest}" \
      '{almalinux: {version: $version_latest }}'
  else
    exit 1
  fi
}


_coverity_version_latest() {

  # retrieve equivalent version of coverity image latest tag
  if version_latest=$(../../../utils/equate_tag "ghcr.io/mantidproject/cov-analysis-linux64:latest" | jq -r '.[]')
  then
    echo '{}' \
      | jq -r \
        --compact-output \
        --arg version_latest "$(../../../utils/equate_tag "ghcr.io/mantidproject/cov-analysis-linux64:latest" | jq -r '.[]')" \
      '{coverity: {version: $version_latest }}'
  else
    exit 1
  fi
}


_gha_runner_version_latest() {

  # retrieve version and download_url for github actions runner
  if ! jq -e --compact-output '{
      gha_runner: {
        download_url: (.assets[] | select(.name | test("linux-x64")) | .browser_download_url),
        version: (.name)
      }
    }' <<< "$(curl -s https://api.github.com/repos/actions/runner/releases/latest)" 2>/dev/null
  then
    echo "Error parsing GitHub API response" >&2
    exit 1
  fi
}

__build_manifest() {

  (
    _almalinux_version_latest
    _coverity_version_latest
    _gha_runner_version_latest
  ) \
    | jq -r -s --compact-output '. | add'
}

__build_all() {

  __build_manifest
  podman build \
    --squash-all \
    --format oci \
    --annotation "org.opencontainers.image.title=SNS Github Runner" \
    --annotation "org.opencontainers.image.description=SNSGithubRunner" \
    --
}


if test -z "$1"; then
  "__build_all"
else
  "__build_$1"
fi




