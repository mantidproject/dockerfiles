# syntax=docker/dockerfile:1.6

ARG SEMVER_TAG

FROM almalinux:latest
RUN SEMVER_TAG=$(cat /etc/os-release | grep '^VERSION_ID=.*' | cut -d'=' -f2 | tr -d '"')

FROM alpine
RUN echo $SEMVER_TAG > /SEMVER_TAG

#FROM almalinux:latest
#COPY --from=0 /etc/os-release /tmp/base-os-release





