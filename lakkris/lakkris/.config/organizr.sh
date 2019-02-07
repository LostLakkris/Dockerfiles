#!/bin/bash
source /tmp/lakkris.env
CONFIG_FILE="/config/nginx/site-confs/default"
while [[ ! -e "${CONFIG_FILE}" ]]; do
	sleep 1s
done

s6-svwait -u "/var/run/s6/services/nginx" "/var/run/s6/services/php-fpm"

if [[ ! -d /config/nginx/lakkris ]]; then
	mkdir /config/nginx/lakkris
fi
if [[ ! -d /config/nginx/tmp ]]; then
	mkdir /config/nginx/tmp
fi

CONTENT="include /config/nginx/lakkris/*.conf;"

CONFIG_MD5_START=$(md5sum ${CONFIG_FILE} | awk '{print $1}')
grep -q -x -F "${CONTENT}" ${CONFIG_FILE} || sed -i "s#^}#${CONTENT}\n}#g" ${CONFIG_FILE}
CONFIG_MD5_END=$(md5sum ${CONFIG_FILE} | awk '{print $1}')

if [[ $(s6-svstat -u "/var/run/s6/services/nginx") == "true" && "${CONFIG_MD5_START}" != "${CONFIG_MD5_END}" ]]; then
	s6-svc -h "/var/run/s6/services/nginx"
fi
