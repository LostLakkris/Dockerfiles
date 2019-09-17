#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${DIR}

docker-compose \
  -f docker-compose.normal.yml \
  up -d --remove-orphans --build
