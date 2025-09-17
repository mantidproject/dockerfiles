# syntax=docker/dockerfile:1.6

ARG SEMVER_TAG

FROM almalinux:latest

FROM scratch
COPY --from=0 /etc/os-release /tmp/base-os-release
RUN SEMVER_TAG=$(cat /tmp/base-os-release | grep '^VERSION_ID=.*' | cut -d'=' -f2 | tr -d '"')




