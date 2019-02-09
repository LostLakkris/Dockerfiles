#!/bin/bash
event="${1}"
object="${2}"
source /tmp/lakkris.env
NOTIFY_FILE="/tmp/lakkris.notify"

if [[ -e "${NOTIFY_FILE}" ]]; then
	(
		exec 203>> "/tmp/lakkris.lock"
		RUN_SCRIPT=$(grep "^${object}:${event}," "${NOTIFY_FILE}" | cut -d',' -f2-)
		if [[ -x "${RUN_SCRIPT}" ]]; then
			bash "${RUN_SCRIPT}"
		fi
		flock -u 203
	) &>/dev/null &
fi
