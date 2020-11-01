#!/bin/bash
set -e
apk add --no-cache \
      git wget zip tar xz curl \
      nodejs npm python3 \
      pkgconfig \
      cairo cairo-dev pango pango-dev libjpeg-turbo libjpeg-turbo-dev \
      ffmpeg
apk add --no-cache --virtual .build-dependencies build-base g++ make

git clone --single-branch --branch dev --depth 1 https://gitlab.com/Shinobi-Systems/Shinobi.git /opt/shinobi
cd /opt/shinobi && /usr/bin/npm install --unsafe-perm && /usr/bin/npm audit fix --force
apk del .build-dependencies
