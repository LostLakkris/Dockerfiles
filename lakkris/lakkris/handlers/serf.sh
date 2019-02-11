#!/bin/bash
PAYLOAD=$(cat)
source /tmp/lakkris.env
echo "$(date +%s) - $$ - $0 - $@" >> /tmp/debug.log

HANDLER_ROOT="/lakkris/events-serf/${LAKKRIS_SERVICE}"

if [[ -x "${HANDLER_ROOT}/${SERF_EVENT}" ]]; then
	(
		exec 200>> "/tmp/lakkris-serf.lock"
		flock -x -w 2 200
		echo "${PAYLOAD}" | exec "${HANDLER_ROOT}/${SERF_EVENT}"
		# Rerun the serf script again incase environment changed
		if [[ -x /lakkris/start-pre/serf.sh ]]; then
			bash /lakkris/start-pre/serf.sh
		fi
		flock -u 200
	) &>/dev/null &
fi
