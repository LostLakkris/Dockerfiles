#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
CONFIG_FILE=${LAKKRIS_CONFIGFILE}
LAKKRIS_CONFIG="/config/nginx/lakkris"
ORGANIZR_CONFIG="/config/www/Dashboard/api/config/config.php"
CURL="/lakkris/curl/${LAKKRIS_SERVICE}.sh"

# Wait for all services
for service in 'serf' 'nginx' 'php-fpm' 'cron'; do
	while [[ ! -e "${CONFIG_FILE}" || ! -d "/var/run/s6/services/${service}" || $(s6-svstat -u "/var/run/s6/services/${service}") != "true" ]]; do
		sleep 1s
	done
done

# wait for port up
PORT_UP=1
while [[ $PORT_UP -ne 0 ]]; do
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
	ICON=$(echo "${DATA}" | jq -c --raw-output '.tags.LAKKRIS_ICON')
	if [[ "${SERVER}" != "null" && "${SERVICE}" != "null" ]]; then
		echo "${DATA}" | jq -c --raw-output '.tags | to_entries[] | (.key | ascii_upcase) + "=" + .value' > /tmp/service-$$.env
		if [[ "${SERVICE}" == "nzbget" || "${SERVICE}" == "plex" || $(grep '^LAKKRIS_WEBROOT=' /tmp/service-$$.env | wc -l) -gt 0 ]]; then
			templater /lakkris/templates/nginx/${SERVICE}.conf -f /tmp/service-$$.env -s > "${LAKKRIS_CONFIG}/100-${SERVER}-${SERVICE}.conf"
		fi
		# TODO: Can't seem to build a curl query that actually works against whatever API organizr thinks they've designed
		if [[ 0 -eq 1 ]]; then
			TAB_NAME="[${SERVER}] ${SERVICE}"
			TAB_URL="/${SERVER}-${SERVICE}"
			# Check if tab already exists
			EXISTS=$(bash ${CURL} -u "tab/list" | jq -c --raw-output --arg url "${TAB_URL}" '.data.tabs[]|select(.url==$url)|.id' | head -n 1)
			# Create if not
			if [[ -z "${EXISTS}" || "${EXISTS}" == "null" ]]; then
				PAYLOAD=$()
				bash ${CURL} -u "settings/tab/editor/tabs" -c 'application/x-www-form-urlencoded; charset=UTF-8' -m POST \
					--data "=data[action]=addNewTab" --data "=data[api]=api/?v1/settings/tab/editor/tabs" --data "=data[tabOrder]=5" \
					--data "=data[tabName]=${TAB_NAME}" --data "=data[tabImage]=${ICON}" --data "=data[tabURL]=${TAB_URL}" --data "=data[tabLocalURL]=${TAB_URL}" \
					--data "=data[pingURL]=" --data "=data[tabGroupID]=5" --data "=data[tabEnabled]=1" --data "=data[tabDefault]=0" --data "=data[tabType]=1"
			fi
		fi
		rm /tmp/service-$$.env
	fi
done
HASH_END=$(md5sum "${CONFIG_FILE}" ${LAKKRIS_CONFIG}/* | sort | md5sum | awk '{print $1}')

if [[ "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/nginx"
	s6-svwait -u "/var/run/s6/services/nginx"
fi

IFS=$OIFS
