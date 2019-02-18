#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
CONFIG_FILE=${LAKKRIS_CONFIGFILE}
LAKKRIS_CONFIG="/config/nginx/lakkris"

# Confirm serf is running
while [[ ! -d "/var/run/s6/services/serf" || $(s6-svstat -u "/var/run/s6/services/serf") != "true" ]]; do
	sleep 1s
done

# Wait for primary service
PORT_UP=1
while [[ ! -e "${CONFIG_FILE}" || ! -d "/var/run/s6/services/nginx" || $(s6-svstat -u "/var/run/s6/services/nginx") != "true" || $PORT_UP -ne 0 ]]; do
	sleep 1s
	if [[ ${PORT_UP} -ne 0 ]]; then
		nc -z 127.0.0.1 ${LAKKRIS_PORT}
		PORT_UP=$?
	fi
done

# Feel free to configure
HASH_START=$(md5sum "${CONFIG_FILE}" ${LAKKRIS_CONFIG}/* | sort | md5sum | awk '{print $1}')

if [[ ! -d "${LAKKRIS_CONFIG}" ]]; then
	mkdir "${LAKKRIS_CONFIG}"
fi
if [[ ! -e ${LAKKRIS_CONFIG}/000-authblock.conf ]]; then
	cp /lakkris/templates/nginx/000-authblock.conf ${LAKKRIS_CONFIG}/000-authblock.conf
fi

LINE="include ${LAKKRIS_CONFIG}/*.conf;"
grep -q -x -F "${LINE}" "${CONFIG_FILE}" || sed -i "s#^}#${LINE}\n}#g" "${CONFIG_FILE}"

SVCS=( $(serf members -format=json | jq -c --raw-output '.members|sort_by(.tags.LAKKRIS_START)|.[]|select(.status=="alive")') )
for DATA in ${SVCS[@]}; do
	SERVER=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_SERVERNAME')
	SERVICE=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_SERVICE')
	if [[ "${SERVER}" != "null" && "${SERVICE}" != "null" ]]; then
		echo "${DATA}" | jq -c --raw-output '.tags | to_entries[] | (.key | ascii_upcase) + "=" + .value' > /tmp/service-$$.env
		if [[ "${SERVICE}" == "nzbget" || "${SERVICE}" == "plex" || $(grep '^LAKKRIS_WEBROOT=' /tmp/service-$$.env | wc -l) -gt 0 ]]; then
			templater /lakkris/templates/nginx/${SERVICE}.conf -f /tmp/service-$$.env -s > "${LAKKRIS_CONFIG}/100-${SERVER}-${SERVICE}.conf"
		fi
# TODO: If organizr token is known, auto-generate some tabs?
		rm /tmp/service-$$.env
	fi
done
HASH_END=$(md5sum "${CONFIG_FILE}" ${LAKKRIS_CONFIG}/* | sort | md5sum | awk '{print $1}')

if [[ "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/nginx"
	s6-svwait -u "/var/run/s6/services/nginx"
fi

IFS=$OIFS
