#!/bin/bash
source /tmp/lakkris.env
#CONFIG_FILE="/config/nginx/site-confs/default"
CONFIG_FILE=${LAKKRIS_CONFIGFILE}
LAKKRIS_CONFIG="/config/nginx/lakkris"

if [[ -e "${CONFIG_FILE}" ]]; then
	if [[ ! -d "${LAKKRIS_CONFIG}" ]]; then
		mkdir "${LAKKRIS_CONFIG}"
	fi
	HASH_START=$(md5sum "${CONFIG_FILE}" ${LAKKRIS_CONFIG}/* | sort -n | md5sum | awk '{print $1}')

	if [[ ! -e /config/nginx/lakkris/000-authblock.conf ]]; then
		cp /lakkris/templates/nginx/000-authblock.conf ${LAKKRIS_CONFIG}/000-authblock.conf
	fi

	LINE="include ${LAKKRIS_CONFIG}/*.conf;"
	grep -q -x -F "${LINE}" "${CONFIG_FILE}" || sed -i "s#^}#${LINE}\n}#g" "${CONFIG_FILE}"

	# Cluster detected things
	if [[ -d "/var/run/s6/services/serf" && $(s6-svstat -u "/var/run/s6/services/serf") == "true" ]]; then
		SVCS=( $(serf members -format=json | jq -c --raw-output '.members|sort_by(.tags.LAKKRIS_START)|.[]|select(.status=="alive")') )
		for DATA in ${SVCS[@]}; do
			SERVER=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_SERVERNAME')
			SERVICE=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_SERVICE')
			WEBROOT=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_WEBROOT')
			if [[ "${SERVER}" != "null" && "${SERVICE}" != "null" && -e "/lakkris/templates/nginx/${SERVICE}.conf" ]]; then
				echo "${DATA}" | jq -c --raw-output '.tags | to_entries[] | (.key | ascii_upcase) + "=" + .value' > /tmp/service-$$.env
				if [[ "${SERVICE}" == "nzbget" || "${SERVICE}" == "plex" || $(grep '^LAKKRIS_WEBROOT=' /tmp/service-$$.env | wc -l) -gt 0 ]]; then
					templater /lakkris/templates/nginx/${SERVICE}.conf -f /tmp/service-$$.env -s > "${LAKKRIS_CONFIG}/100-${SERVER}-${SERVICE}.conf"
				fi
# TODO: Check if apitoken exists, auto-generate tabs
				rm /tmp/service-$$.env
			fi
		done
	fi

	HASH_END=$(md5sum "${CONFIG_FILE}" ${LAKKRIS_CONFIG}/* | sort -n | md5sum | awk '{print $1}')
	if [[ -d "/var/run/s6/services/nginx" && $(s6-svstat -u "/var/run/s6/services/nginx") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
		s6-svc -h "/var/run/s6/services/nginx"
		s6-svwait -u "/var/run/s6/services/nginx"
	fi
fi
