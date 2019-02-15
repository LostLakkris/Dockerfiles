#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
CONFIG_FILE=${LAKKRIS_CONFIGFILE}
DATA_ROOT=${DATA_ROOT:-/downloads/completed}

# Confirm serf is running
while [[ ! -d "/var/run/s6/services/serf" || $(s6-svstat -u "/var/run/s6/services/serf") != "true" ]]; do
	sleep 1s
done

# Wait for primary service
PORT_UP=1
while [[ ! -e "${CONFIG_FILE}" || ! -d "/var/run/s6/services/${LAKKRIS_SERVICE}" || $(s6-svstat -u "/var/run/s6/services/${LAKKRIS_SERVICE}") != "true" || $PORT_UP -ne 0 ]]; do
	sleep 1s
	if [[ ${PORT_UP} -ne 0 ]]; then
		nc -z 127.0.0.1 ${LAKKRIS_PORT}
		PORT_UP=$?
	fi
done

# Feel free to configure
HASH_START=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')
SVCS=( $(serf members -format=json | jq -c --raw-output '.members|sort_by(.tags.LAKKRIS_START)|.[]|select(.status=="alive")') )
for DATA in ${SVCS[@]}; do
	# TODO: Find and configure nzbget automagically
	# TODO: Find and configure nzbhydra automagically
	echo "TODO: Find nzbget and nzbhydra, and autoconfig that."
done
HASH_END=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')

if [[ "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/${LAKKRIS_SERVICE}"
	s6-svwait -u "/var/run/s6/services/${LAKKRIS_SERVICE}"
fi

IFS=$OIFS
