#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
CONFIG_FILE=${LAKKRIS_CONFIGFILE}
DATA_ROOT=${DATA_ROOT:-/downloads/completed}
CURL=/lakkris/curl/${LAKKRIS_SERVICE}.sh

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
#CLIENTS=$(bash ${CURL} -u downloadclient | jq -c --raw-output '.')
#INDEXERS=$(bash ${CURL} -u indexer | jq -c --raw-output '.')
SVCS=( $(serf members -format=json | jq -c --raw-output '.members|sort_by(.tags.LAKKRIS_START)|.[]|select(.status=="alive")') )
for DATA in ${SVCS[@]}; do
	SERVICE=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_SERVICE')
	if [[ -d "/lakkris/templates/curl/${LAKKRIS_SERVICE}/${SERVICE}" ]]; then
		( echo "${DATA}" | jq -c --raw-output '.tags | to_entries[] | (.key | ascii_upcase) + "=" + .value' | sed 's@^LAKKRIS_@REMOTE_@g' ; sed 's@^export LAKKRIS_@LOCAL_@g' /tmp/lakkris.env ) > /tmp/service-$$.env
		for uri in $(ls -1 "/lakkris/templates/curl/${LAKKRIS_SERVICE}/${SERVICE}/"); do
			REMOTE_DATA=$(bash ${CURL} -u ${uri} | jq -c --raw-output '.')
			PAYLOAD=$(templater /lakkris/templates/curl/${LAKKRIS_SERVICE}/${SERVICE}/${uri} -f /tmp/service-$$.env -s | jq -c --raw-output '.')
			NAME=$(echo "${PAYLOAD}" | jq -c --raw-output '.name')
			EXISTS=$(echo "${REMOTE_DATA}" | jq -c --raw-output --arg name "${NAME}" '.[]|select(.name==$name)|.id' | head -n 1)
			if [[ -n "${EXISTS}" && "${EXISTS}" != "null" ]]; then
				## TODO: Compare and Update, not just update
				## update
				bash ${CURL} -u "${uri}/${EXISTS}" -m PUT -p "${PAYLOAD}"
			else
				## create
				bash ${CURL} -u "${uri}" -m POST -p "${PAYLOAD}"
			fi
		done
		rm /tmp/service-$$.env
	fi
done
HASH_END=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')

if [[ "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/${LAKKRIS_SERVICE}"
	s6-svwait -u "/var/run/s6/services/${LAKKRIS_SERVICE}"
fi

IFS=$OIFS
