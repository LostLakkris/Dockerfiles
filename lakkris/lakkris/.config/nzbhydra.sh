#!/bin/bash
source /tmp/lakkris.env
CONFIG_FILE="/config/nzbhydra.yml"
while [[ ! -e "${CONFIG_FILE}" ]]; do
	sleep 1s
done

s6-svwait -u "/var/run/s6/services/${LAKKRIS_SERVICE}"

if [[ -z "${LAKKRIS_WEBROOT}" ]]; then
	LAKKRIS_WEBROOT="${LAKKRIS_SERVERNAME}-${LAKKRIS_SERVICE}"
fi
CONFIG_STRING='s@urlBase:.*@urlBase: "/'${LAKKRIS_WEBROOT}'"@g'
CONFIG_MD5_START=$(md5sum ${CONFIG_FILE} | awk '{print $1}')
sed -i "${CONFIG_STRING}" "${CONFIG_FILE}"
CONFIG_MD5_END=$(md5sum ${CONFIG_FILE} | awk '{print $1}')

if [[ $(s6-svstat -u "/var/run/s6/services/nzbhydra2") == "true" && "${CONFIG_MD5_START}" != "${CONFIG_MD5_END}" ]]; then
	s6-svc -wD -d "/var/run/s6/services/nzbhydra2"
	s6-svwait -d "/var/run/s6/services/nzbhydra2"
	sed -i "${CONFIG_STRING}" ${CONFIG_FILE}
	s6-svc -wU -u "/var/run/s6/services/nzbhydra2"
	s6-svwait -u "/var/run/s6/services/nzbhydra2"
fi

# Confirming the webroot is still modified
LAKKRIS_WEBROOT_FILE=$(awk '/urlBase: /{print $NF}' ${CONFIG_FILE} | tr -d '"/')
if [[ "${LAKKRIS_WEBROOT}" == "${LAKKRIS_WEBROOT_FILE}" ]]; then
	UPDATE="export LAKKRIS_WEBROOT=${LAKKRIS_WEBROOT}"
	grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
fi

LAKKRIS_APITOKEN=$(awk '/apiKey: /{print $NF}' ${CONFIG_FILE} | tr -d '"')
UPDATE="export LAKKRIS_APITOKEN=${LAKKRIS_APITOKEN}"
grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env

