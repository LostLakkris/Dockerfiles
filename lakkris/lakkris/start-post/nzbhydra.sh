#!/bin/bash
OIFS=$IFS
IFS=$'\n'
source /tmp/lakkris.env
#CONFIG_FILE="/config/nzbhydra.yml"
CONFIG_FILE=${LAKKRIS_CONFIGFILE}

## NZBhydra's startup sequence results in the service starting, the root config file being created, but still has another 20-30s of database migrations before it's ready
## This results in some order of operations issues as the config file will get reset
## This script should only exec after services have begun(start-post), so extra checks are present

# Wait for config file, then service directory, then if service is running
PORT_UP=1
while [[ ! -e "${CONFIG_FILE}" || ! -d "/var/run/s6/services/nzbhydra2" || $(s6-svstat -u "/var/run/s6/services/nzbhydra2") != "true" || $PORT_UP -ne 0 ]]; do
	sleep 1s
	if [[ ${PORT_UP} -ne 0 ]]; then
		nc -z 127.0.0.1 ${LAKKRIS_PORT}
		PORT_UP=$?
	fi
done

if [[ -e "${CONFIG_FILE}" ]]; then
	HASH_START=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')
	if [[ -z "${LAKKRIS_WEBROOT}" ]]; then
		LAKKRIS_WEBROOT="${LAKKRIS_SERVERNAME}-${LAKKRIS_SERVICE}"
	fi

	CONFIG=(
		"s@urlBase:.*@urlBase: /${LAKKRIS_WEBROOT}@g"
	)

	for STRING in ${CONFIG[@]}; do
		sed -i "${STRING}" "${CONFIG_FILE}"
	done

	HASH_END=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')
	if [[ -d "/var/run/s6/services/nzbhydra2" && $(s6-svstat -u "/var/run/s6/services/nzbhydra2") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
		s6-svc -wD -d "/var/run/s6/services/nzbhydra2"
		s6-svwait -d "/var/run/s6/services/nzbhydra2"
		for STRING in ${CONFIG[@]}; do
			sed -i "${STRING}" "${CONFIG_FILE}"
		done
		s6-svc -wU -u "/var/run/s6/services/nzbhydra2"
		s6-svwait -u "/var/run/s6/services/nzbhydra2"
	fi

	LAKKRIS_APITOKEN=$(awk '/apiKey: /{print $NF}' ${CONFIG_FILE} | tr -d '"')
	UPDATE="export LAKKRIS_APITOKEN=${LAKKRIS_APITOKEN}"
	grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env

	# Confirming webroot is still modified
	LAKKRIS_WEBROOT_FILE=$(awk '/urlBase: /{print $NF}' ${CONFIG_FILE} | tr -d '"/')
	if [[ "${LAKKRIS_WEBROOT}" == "${LAKKRIS_WEBROOT_FILE}" ]]; then
		UPDATE="export LAKKRIS_WEBROOT=${LAKKRIS_WEBROOT}"
		grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
	fi

#### All services should be up and file-configured by now
	# Cluster detected things
	if [[ -d "/var/run/s6/services/serf" && $(s6-svstat -u "/var/run/s6/services/serf") == "true" ]]; then
		SVCS=( $(serf members -format=json | jq -c --raw-output '.members[]') )
		# TODO: Find and configure nzbget automagically
	fi
fi
IFS=$OIFS
