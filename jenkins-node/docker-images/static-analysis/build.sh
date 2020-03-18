#!/bin/sh

docker build \
  --file Dockerfile \
  -t mantidproject/static-analysis-node:latest \
  .
