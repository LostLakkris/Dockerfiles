#!/bin/bash
PAYLOAD=$(cat)
source /tmp/lakkris.env
echo "$(date +%s) - $$ - $0 - $@" >> /tmp/debug.log

HANDLER_ROOT="/lakkris/events-serf/${LAKKRIS_SERVICE}"

if [[ -x "${HANDLER_ROOT}/${SERF_EVENT}" ]]; then
	(
		exec 200>> "/tmp/lakkris-handler.lock"
		flock -n -x 200
		echo "${PAYLOAD}" | exec "${HANDLER_ROOT}/${SERF_EVENT}"
		flock -u 200
	) &>/dev/null &
fi
