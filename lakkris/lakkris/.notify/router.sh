#!/bin/bash
event="${1}"
object="${2}"

source /tmp/lakkris.env

if [[ "${object}" == "/tmp/lakkris.notify" ]]; then
	if [[ -s /tmp/lakkris.notify ]]; then
		s6-svc -wr /var/run/s6/services/inotifyd
	elif [[ -e /tmp/lakkris.notify && ! -s /tmp/lakkris.notify ]]; then
		s6-svc -wD /var/run/s6/services/inotifyd
	fi
elif [[ -e "/tmp/lakkris.notify" ]]; then
	SCRIPT=$(grep "^${object}:${event}" "/tmp/lakkris.notify" | cut -d',' -f2-)
	if [[ -x "${SCRIPT}" ]]; then
		bash "${SCRIPT}"
	fi
fi
