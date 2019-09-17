#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${DIR}

docker-compose -H=unix:///var/run/weave/weave.sock \
  -f docker-compose.weave.yml \
  up -d --remove-orphans --build
