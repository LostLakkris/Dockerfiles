#!/bin/bash
PAYLOAD=$(cat)
source /tmp/lakkris.env

HANDLER_ROOT="/lakkris/events-serf/${LAKKRIS_SERVICE}"

if [[ ! -d "${HANDLER_ROOT}" ]]; then
	exit 0
fi

if [[ -x "${HANDLER_ROOT}/${SERF_EVENT}" ]]; then
	(
		exec 203>> "/tmp/lakkris.lock"
		flock -n -x 203
		echo "${PAYLOAD}" | exec "${HANDLER_ROOT}/${SERF_EVENT}"
		flock -u 203
	) &>/dev/null &
fi
