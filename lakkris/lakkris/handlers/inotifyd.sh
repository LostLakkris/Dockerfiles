#!/bin/bash
event="${1}"
object="${2}"
source /tmp/lakkris.env
NOTIFY_FILE="/tmp/lakkris.notify"

echo "$(date +%s) - $$ - $0 - $@" >> /tmp/debug.log

if [[ -e "${NOTIFY_FILE}" ]]; then
	(
		exec 300>> "/tmp/lakkris-inotify.lock"
		flock -x -w 2 300
		RUN_SCRIPT=$(grep "^${object}:${event}," "${NOTIFY_FILE}" | cut -d',' -f2-)
		if [[ -x "${RUN_SCRIPT}" ]]; then
			bash "${RUN_SCRIPT}"
		fi
		flock -u 300
	) &>/dev/null &
fi
