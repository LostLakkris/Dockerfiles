#!/bin/bash
source /tmp/lakkris.env
OIFS=$IFS
IFS=$'\n'

if [[ -z "${LAKKRIS_WEBROOT}" ]]; then
	LAKKRIS_WEBROOT="${LAKKRIS_SERVERNAME}/${LAKKRIS_SERVICE}"
fi

# Shinobi base conf
if [[ -e "/config/shinobi/conf.json" ]]; then
	CRON_KEY=$(jq -c --raw-output '.cron.key' "/config/shinobi/conf.json")
	if [[ "${CRON_KEY}" == "change_this_to_something_very_random__just_anything_other_than_this" ]]; then
		CRON_KEY=$(cat /proc/sys/kernel/random/uuid)
	fi
	BASE_CONFIG=$(jq -c --raw-output \
		--arg cronkey "${CRON_KEY}" \
		--arg home "/${LAKKRIS_WEBROOT}" \
		--arg admin "/${LAKKRIS_WEBROOT}/admin" \
		--arg super "/${LAKKRIS_WEBROOT}/super" \
		'.webPaths.home=$home|.webPaths.admin=$admin|.webPaths.super=$super|.cron.key=$cronkey' "/config/shinobi/conf.json")
	echo "${BASE_CONFIG}" | jq --raw-output '.' > "/config/shinobi/conf.json"

	UPDATE="export LAKKRIS_WEBROOT=${LAKKRIS_WEBROOT}"
	grep -q "${UPDATE%=*}" /tmp/lakkris.env && sed -i "s@${UPDATE%=*}.*@${UPDATE}@" /tmp/lakkris.env || echo "${UPDATE}" >> /tmp/lakkris.env
fi

if [[ -e "/config/shinobi/motion.json" ]]; then
	BASE_CONFIG=$(jq -c --raw-output '.' "/config/shinobi/conf.json")
	MOTION_CONFIG=$(jq -c --raw-output '.' "/config/shinobi/motion.json")

	BASE_CRON_KEY=$(echo "${BASE_CONFIG}" | jq -c --raw-output '.pluginKeys.Motion')
	MOTION_CRON_KEY=$(echo "${MOTION_CONFIG}" | jq -c --raw-output '.key')
	
	if [[ "${BASE_CRON_KEY}" == "null" || "${MOTION_CRON_KEY}" == "change_this_to_something_very_random____make_sure_to_match__/plugins/motion/conf.json" || "${BASE_CRON_KEY}" != "${MOTION_CRON_KEY}" ]]; then
		NEW_KEY=$(cat /proc/sys/kernel/random/uuid)
		BASE_CONFIG=$(echo "${BASE_CONFIG}" | jq -c --raw-output --arg key "${NEW_KEY}" '.pluginKeys.Motion=$key')
		MOTION_CONFIG=$(echo "${MOTION_CONFIG}" | jq -c --raw-output --arg key "${NEW_KEY}" '.key=$key')
	fi
	echo "${BASE_CONFIG}" | jq --raw-output '.' > "/config/shinobi/conf.json"
	echo "${MOTION_CONFIG}" | jq --raw-output '.' > "/config/shinobi/motion.json"
fi

IFS=$OIFS
