#!/bin/bash
source /tmp/lakkris.env
CONFIG_FILE="/config/nginx/site-confs/default"
while [[ ! -e "${CONFIG_FILE}" ]]; do
	sleep 1s
done
while [[ $(curl -fsS localhost:${LAKKRIS_PORT:-80} &>/dev/null) -ne 0 ]]; do
        sleep 1s
done

if [[ ! -d /config/nginx/lakkris ]]; then
	mkdir /config/nginx/lakkris
fi

if [[ ! -e /config/nginx/lakkris/000-authblock.conf ]]; then
	cp /lakkris/tmpl/nginx/000-authblock.conf /config/nginx/lakkris/000-authblock.conf
fi
touch /config/nginx/lakkris.conf

CONTENT="include /config/nginx/lakkris.conf;"

CONFIG_MD5_START=$(md5sum ${CONFIG_FILE} | awk '{print $1}')
grep -q -x -F "${CONTENT}" ${CONFIG_FILE} || sed -i "s#^}#${CONTENT}\n}#g" ${CONFIG_FILE}
CONFIG_MD5_END=$(md5sum ${CONFIG_FILE} | awk '{print $1}')

if [[ "${CONFIG_MD5_START}" != "${CONFIG_MD5_END}" && $(s6-svstat -u "/var/run/s6/services/nginx") ]]; then
	s6-svc -h "/var/run/s6/services/nginx"
fi
