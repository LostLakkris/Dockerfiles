#!/bin/bash
event="${1}"
object="${2}"

source /tmp/lakkris.env

if [[ -e "/lakkris/.notify/map.${LAKKRIS_SERVICE}" ]]; then
	SCRIPT=$(grep "^${object}:${event}" "/lakkris/.notify/map.${LAKKRIS_SERVICE}" | cut -d',' -f2-)
	if [[ -x "${SCRIPT}" ]]; then
		bash "${SCRIPT}"
	fi
fi
