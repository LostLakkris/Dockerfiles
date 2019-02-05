#!/bin/bash
source /tmp/lakkris.env
CONFIG_FILE="/config/nzbget.conf"
while [[ ! -e "${CONFIG_FILE}" ]]; do
	sleep 1s
done
while ! nc -z 127.0.0.1 ${LAKKRIS_PORT} ; do
	sleep 1s
done

# TODO: use a hash to generate a random-feeling but repeatable password
LAKKRIS_USERNAME="${LAKKRIS_SERVERNAME}"
LAKKRIS_PASSWORD="${LAKKRIS_SERVERNAME}"
CONFIG_STRINGS=(
	's@^RestrictedUsername=.*@RestrictedUsername='${LAKKRIS_USERNAME}'@g'
	's@^RestrictedPassword=.*@RestrictedPassword='${LAKKRIS_PASSWORD}'@g'
)

CONFIG_MD5_START=$(md5sum ${CONFIG_FILE} | awk '{print $1}')
for CONFIG_STRING in ${CONFIG_STRINGS[@]}; do
        sed -i "${CONFIG_STRING}" "${CONFIG_FILE}"
done
CONFIG_MD5_END=$(md5sum ${CONFIG_FILE} | awk '{print $1}')

if [[ $(s6-svstat -u "/var/run/s6/services/${LAKKRIS_SERVICE}") == "true" && "${CONFIG_MD5_START}" != "${CONFIG_MD5_END}" ]]; then
	s6-svc -h "/var/run/s6/services/${LAKKRIS_SERVICE}"
fi

## Update lakkris.env
UPDATE="export LAKKRIS_USERNAME=\"${LAKKRIS_USERNAME}\""
grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
UPDATE="export LAKKRIS_PASSWORD=\"${LAKKRIS_PASSWORD}\""
grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
