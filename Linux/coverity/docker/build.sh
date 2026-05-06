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


_target_image_version_next() {

  # retrieve and equate the latest tag with existing integer version
  version_latest=$(../../../utils/equate_tag "ghcr.io/mantidproject/github-runner-coverity:latest" | jq -r '.[] | select(match("^v\\d+$"))')
  if [[ -n ${version_latest} ]]; then
    echo '{}' \
      | jq -r --compact-output \
        --arg v "${version_latest}" \
        '
          ($v | capture("^(?<p>[^0-9]*)(?<n>[0-9]+)$")) as $parts
          | ($parts.n | length) as $width
          | ($parts.n | tonumber + 1 | tostring) as $next
          | {target_image: {version_next:
            ($parts.p + ("0" * ($width - ($next | length)) + $next))}}
        '
      #
      # preserve zero-padded version and increment the integer version by 1
      #
  else
    exit 1
  fi
}

__preflight() {

  script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )"
  cd ${script_dir}
}

__build_manifest() {

  (
    _almalinux_version_latest
    _coverity_version_latest
    _gha_runner_version_latest
    _target_image_version_next
  ) \
    | jq -r -s --compact-output '. | add'
}

__build_all() {

  read -r manifest <<< $(__build_manifest)

  read -r ALMALINUX_VERSION    <<< $(echo ${manifest} | jq -r '.almalinux.version')
  read -r COVERITY_VERSION     <<< $(echo ${manifest} | jq -r '.coverity.version')
  read -r GHA_RUNNER_VERSION   <<< $(echo ${manifest} | jq -r '.gha_runner.version')
  read -r GHA_RUNNER_DOWNLOAD  <<< $(echo ${manifest} | jq -r '.gha_runner.download_url')
  read -r VERSION_NEXT         <<< $(echo ${manifest} | jq -r '.target_image.version_next')

  # If VERSION_NEXT is empty, set a default value
  VERSION_NEXT="${VERSION_NEXT:-v001}"

  podman build \
      --squash-all \
      --format oci \
      --annotation "org.opencontainers.image.title=Github Runner with Coverity" \
      --annotation "org.opencontainers.image.description=[${VERSION_NEXT}] Github Runner w/ Coverity ${COVERITY_VERSION} on AlmaLinux ${ALMALINUX_VERSION}" \
      --tag "ghcr.io/mantidproject/github-runner-coverity:${VERSION_NEXT}" \
      --tag "ghcr.io/mantidproject/github-runner-coverity:latest" \
      --build-arg "ALMALINUX_VERSION=${ALMALINUX_VERSION}" \
      --build-arg "COVERITY_VERSION=${COVERITY_VERSION}" \
      --build-arg "GHA_RUNNER_VERSION=${GHA_RUNNER_VERSION}" \
      --build-arg "GHA_RUNNER_DOWNLOAD=${GHA_RUNNER_DOWNLOAD}" \
    .
}

if test -z "$1"; then
  "__preflight"
  "__build_all"
else
  "__preflight"
  "__build_$1"
fi




