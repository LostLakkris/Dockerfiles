#!/bin/bash
function _log {
	SCOPE=""
	if [[ -n "${DOCKER_ORG}" && -n "${CONTAINER}" ]]; then
		SCOPE="${DOCKER_ORG}/${CONTAINER} "
	fi
	echo "[***] ${STAGE} ${SCOPE:-}- ${@}"
}
