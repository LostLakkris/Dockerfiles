#!/bin/bash
set -e
apk add --no-cache \
	git curl
	nginx php7-fpm \
	php7-json php7-mbstring php7-iconv \
	php7-session php7-xml php7-curl \
	php7-fileinfo php7-gd php7-intl \
	php7-zip php7-pdo php7-pdo_mysql \
	sqlite php7-pdo_sqlite php7-pdo_pgsql \
	php7-pdo_odbc php7-simplexml

git clone --single-branch --branch ${RELEASE} --depth 1 https://github.com/fisharebest/webtrees.git /app
