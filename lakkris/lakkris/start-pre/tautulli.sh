#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
#CONFIG_FILE="/config/config.ini"
CONFIG_FILE=${LAKKRIS_CONFIGFILE}

if [[ -e "${CONFIG_FILE}" ]]; then
	HASH_START=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')
	if [[ -z "${LAKKRIS_WEBROOT}" ]]; then
		LAKKRIS_WEBROOT="${LAKKRIS_SERVERNAME}-${LAKKRIS_SERVICE}"
	fi

	CONFIG=(
		'http_root = /'${LAKKRIS_WEBROOT}''
	)

	for STRING in ${CONFIG[@]}; do
		grep -q "^${STRING%=*}" "${CONFIG_FILE}" && sed -i "s@^${STRING%=*}.*@${STRING}@" "${CONFIG_FILE}" || echo "${STRING}" >> "${CONFIG_FILE}"
	done

	HASH_END=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')
	if [[ -d "/var/run/s6/services/${LAKKRIS_SERVICE}" && $(s6-svstat -u "/var/run/s6/services/${LAKKRIS_SERVICE}") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
		s6-svc -h "/var/run/s6/services/${LAKKRIS_SERVICE}"
		s6-svwait -u "/var/run/s6/services/${LAKKRIS_SERVICE}"
	fi

#	LAKKRIS_APITOKEN=$(grep -oPm1 "(?<=<ApiKey>)[^<]+" "${CONFIG_FILE}")
#	UPDATE="export LAKKRIS_APITOKEN=${LAKKRIS_APITOKEN}"
#	grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
	UPDATE="export LAKKRIS_WEBROOT=${LAKKRIS_WEBROOT}"
	grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
#### All services should be up and file-configured by now
	# Cluster detected things
	if [[ -d "/var/run/s6/services/serf" &&  $(s6-svstat -u "/var/run/s6/services/serf") == "true" ]]; then
		SVCS=( $(serf members -format=json | jq -c --raw-output '.members[]') )
		# TODO: Find and configure nzbget automagically
	fi

fi
IFS=$OIFS
