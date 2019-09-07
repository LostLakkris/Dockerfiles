#!/bin/bash
set -ev
echo "FROM: ${FROM}"
echo "CONTAINER: ${CONTAINER}"
echo "DOCKER_CLI_EXPERIMENTAL: ${DOCKER_CLI_EXPERIMENTAL}"
docker version
