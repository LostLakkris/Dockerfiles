#!/bin/bash
source /tmp/lakkris.env
CONFIG_FILE="/config/config.xml"
while [[ ! -e "${CONFIG_FILE}" ]]; do
	sleep 1s
done

while ! nc -z 127.0.0.1 ${LAKKRIS_PORT} ; do
	sleep 1s
done

if [[ -z "${LAKKRIS_WEBROOT}" ]]; then
	LAKKRIS_WEBROOT="${LAKKRIS_SERVERNAME}-${LAKKRIS_SERVICE}"
fi
CONFIG_STRING="s@<UrlBase>.*</UrlBase>@<UrlBase>/${LAKKRIS_WEBROOT}</UrlBase>@g"
CONFIG_MD5_START=$(md5sum ${CONFIG_FILE} | awk '{print $1}')
sed -i "${CONFIG_STRING}" ${CONFIG_FILE}
CONFIG_MD5_END=$(md5sum ${CONFIG_FILE} | awk '{print $1}')

if [[ $(s6-svstat -u "/var/run/s6/services/${LAKKRIS_SERVICE}") == "true" && "${CONFIG_MD5_START}" != "${CONFIG_MD5_END}" ]]; then
	s6-svc -h "/var/run/s6/services/${LAKKRIS_SERVICE}"
fi

UPDATE="export LAKKRIS_WEBROOT=\"${LAKKRIS_WEBROOT}\""
grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env

LAKKRIS_APITOKEN=$(grep -oPm1 "(?<=<ApiKey>)[^<]+" "${CONFIG_FILE}")
if [[ -n "${LAKKRIS_APITOKEN}" ]]; then
	UPDATE="export LAKKRIS_APITOKEN=\"${LAKKRIS_APITOKEN}\""
	grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
fi
