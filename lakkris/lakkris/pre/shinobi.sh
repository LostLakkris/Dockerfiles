#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'
CONFIG_FILE=${LAKKRIS_CONFIGFILE}

if [[ -z "${LAKKRIS_WEBROOT}" ]]; then
	LAKKRIS_WEBROOT="${LAKKRIS_SERVERNAME}-${LAKKRIS_SERVICE}"
fi

if [[ -e "${CONFIG_FILE}" ]]; then
	CRON_KEY=$(jq -c --raw-output '.cron.key' "${CONFIG_FILE}")
	if [[ "${CRON_KEY}" == "change_this_to_something_very_random__just_anything_other_than_this" ]]; then
		CRON_KEY=$(cat /proc/sys/kernel/random/uuid)
	fi
	CONFIG=$(jq --raw-output \
		--arg cronkey "${CRON_KEY}" \
		--arg home "/${LAKKRIS_WEBROOT}" \
		--arg admin "/${LAKKRIS_WEBROOT}/admin" \
		--arg super "/${LAKKRIS_WEBROOT}/super" \
		'.webPaths.home=$home|.webPaths.admin=$admin|.webPaths.super=$super|.cron.key=$cronkey' "${CONFIG_FILE}")
	echo "${CONFIG}" > "${CONFIG_FILE}"

	UPDATE="export LAKKRIS_WEBROOT=${LAKKRIS_WEBROOT}"
	grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
fi

IFS=$OIFS
