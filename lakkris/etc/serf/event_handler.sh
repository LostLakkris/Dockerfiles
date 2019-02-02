#!/bin/bash
PAYLOAD=$(cat)
source /tmp/lakkris.env
HANDLER_DIR="/lakkris/.events/${LAKKRIS_SERVICE}"

if [[ ! -d "${HANDLER_DIR}" ]]; then
	exit 0
fi

if [[ "$SERF_EVENT" == "user" ]]; then
	EVENT="user:$SERF_USER_EVENT"
	EVENT_PATH="${EVENT//:/\/}"
elif [[ "$SERF_EVENT" == "query" ]]; then
	EVENT="query:$SERF_QUERY_NAME"
	EVENT_PATH="${EVENT//:/\/}"
else
	EVENT=$SERF_EVENT
	EVENT_PATH="${EVENT}"
fi

HANDLER="${HANDLER_DIR}/${EVENT_PATH}"
if [ -d "${HANDLER}" ]; then
(
	exec 203>> "/tmp/lakkris.lock"
	flock -n -x 203
	echo "${PAYLOAD}" | run-parts "${HANDLER}"
	flock -u 203
) &>/dev/null &
elif [ -e "${HANDLER}" ]; then
(
	exec 203>> "/tmp/lakkris.lock"
	flock -n -x 203
	[ -f "$HANDLER" -a -x "$HANDLER" ] && echo "${PAYLOAD}" | exec "$HANDLER" || :
	flock -u 203
) &>/dev/null &
fi
