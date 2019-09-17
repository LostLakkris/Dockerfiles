#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
CONFIG_FILE=${LAKKRIS_CONFIGFILE}
LAKKRIS_CONFIG="/config/nginx/lakkris"

PORT_UP=1
while [[ ! -e "${CONFIG_FILE}" || ! -d "/var/run/s6/services/nginx" || $(s6-svstat -u "/var/run/s6/services/nginx") != "true" || $PORT_UP -ne 0 ]]; do
	sleep 1s
	if [[ ${PORT_UP} -ne 0 ]]; then
		nc -z 127.0.0.1 ${LAKKRIS_PORT}
		PORT_UP=$?
	fi
done

if [[ ! -d "${LAKKRIS_CONFIG}" ]]; then
	mkdir "${LAKKRIS_CONFIG}"
fi

HASH_START=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')

if [[ ! -e ${LAKKRIS_CONFIG}/000-authblock.conf ]]; then
	cp /lakkris/templates/nginx/000-authblock.conf ${LAKKRIS_CONFIG}/000-authblock.conf
fi

LINE="include ${LAKKRIS_CONFIG}/*.conf;"
grep -q -x -F "${LINE}" "${CONFIG_FILE}" || sed -i "s#^}#${LINE}\n}#g" "${CONFIG_FILE}"

HASH_END=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')
if [[ -d "/var/run/s6/services/nginx" && $(s6-svstat -u "/var/run/s6/services/nginx") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/nginx"
	s6-svwait -u "/var/run/s6/services/nginx"
fi

IFS=$OIFS
