#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
#CONFIG_FILE="/config/config.xml"
CONFIG_FILE=${LAKKRIS_CONFIGFILE}

PORT_UP=1
while [[ ! -e "${CONFIG_FILE}" || ! -d "/var/run/s6/services/${LAKKRIS_SERVICE}" || $(s6-svstat -u "/var/run/s6/services/${LAKKRIS_SERVICE}") != "true" || $PORT_UP -ne 0 ]]; do
	sleep 1s
	if [[ ${PORT_UP} -ne 0 ]]; then
		nc -z 127.0.0.1 ${LAKKRIS_PORT}
		PORT_UP=$?
	fi
done

HASH_START=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')

LAKKRIS_USERNAME="${LAKKRIS_USERNAME:-${LAKKRIS_SERVERNAME}}"
LAKKRIS_PASSWORD="${LAKKRIS_PASSWORD:-${LAKKRIS_SERVERNAME}}"

CONFIG=(
	"RestrictedUsername=${LAKKRIS_USERNAME}"
	"RestrictedPassword=${LAKKRIS_PASSWORD}"
)

for STRING in ${CONFIG[@]}; do
	grep -q "^${STRING%=*}" "${CONFIG_FILE}" && sed -i "s@^${STRING%=*}.*@${STRING}@" "${CONFIG_FILE}" || echo "${STRING}" >> "${CONFIG_FILE}"
done

# Cluster detected things
if [[ -d "/var/run/s6/services/serf" && $(s6-svstat -u "/var/run/s6/services/serf") == "true" ]]; then
	SVCS=( $(serf members -format=json | jq -c --raw-output '.members|sort_by(.tags.LAKKRIS_START)|.[]|select(.status=="alive")') )
	for DATA in ${SVCS[@]}; do
		SERVER=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_SERVERNAME')
		SERVICE=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_SERVICE')
		CONTENT=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_CONTENT')
		if [[ "${SERVER}" != "null" && "${SERVICE}" != "null" && "${CONTENT}" != "null" && "${CONTENT}" != "nzb" ]]; then
			for x in "${DATA_ROOT}" "${DATA_ROOT}/${SERVER}" "${DATA_ROOT}/${SERVER}/${CONTENT}"; do
				if [[ ! -d "${x}" ]]; then
					mkdir -p "${x}"
					chown $(id -u abc):$(id -g abc) "${x}"
				fi
			done
			Name="${SERVER}-${CONTENT}"
			DestDir="\${DestDir}/${SERVER}/${CONTENT}"
			Unpack="yes"
			Aliases=$(echo "$Name" | tr '[A-Z]' '[a-z]')
			if ! grep -q "^Category.*\.Name=${Name}$" "${CONFIG_FILE}"; then
				# Get last category
				CATEGORY=$(awk -F '.' '/^Category/{print $1}' ${CONFIG_FILE} | sed 's@Category@@g' | sort -nur | head -n 1)
				NEW_CATEGORY=$(( ${CATEGORY} + 1 ))
				echo "Category${NEW_CATEGORY}.Name=${Name}" >> ${CONFIG_FILE}
				echo "Category${NEW_CATEGORY}.DestDir=${DestDir}" >> ${CONFIG_FILE}
				echo "Category${NEW_CATEGORY}.Unpack=${Unpack}" >> ${CONFIG_FILE}
				echo "Category${NEW_CATEGORY}.Aliases=${Aliases}" >> ${CONFIG_FILE}
			fi
		fi
	done
fi

HASH_END=$(md5sum "${CONFIG_FILE}" | awk '{print $1}')
if [[ -d "/var/run/s6/services/${LAKKRIS_SERVICE}" && $(s6-svstat -u "/var/run/s6/services/${LAKKRIS_SERVICE}") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/${LAKKRIS_SERVICE}"
	s6-svwait -u "/var/run/s6/services/${LAKKRIS_SERVICE}"
fi

UPDATE="export LAKKRIS_USERNAME=${LAKKRIS_USERNAME}"
grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
UPDATE="export LAKKRIS_PASSWORD=${LAKKRIS_PASSWORD}"
grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env

#### All services should be up and file-configured by now
# Cluster detected things
if [[ -d "/var/run/s6/services/serf" && $(s6-svstat -u "/var/run/s6/services/serf") == "true" ]]; then
	SVCS=( $(serf members -format=json | jq -c --raw-output '.members|sort_by(.tags.LAKKRIS_START)|.[]|select(.status=="alive")') )
	# TODO: Find and configure nzbget automagically
	# TODO: Find and configure nzbhydra automagically
fi

IFS=$OIFS
