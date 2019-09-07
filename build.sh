#!/bin/bash
set -ev
echo "CONTAINER: ${CONTAINER}"
echo "FROM: ${FROM}"
echo "DOCKER_CLI_EXPERIMENTAL: ${DOCKER_CLI_EXPERIMENTAL}"
docker version

if [[ -n "${FROM}" ]]; then
	echo "== Checking available origin ARCHs"
	for PLAT in $(docker manifest inspect "${FROM}" | jq -c --raw-output '.manifests[].platform'); do
		PLAT_OS=$(echo "${PLAT}" | jq -c --raw-output '.os')
		PLAT_ARCH=$(echo "${PLAT}" | jq -c --raw-output '.architecture')
		PLAT_VARIANT=$(echo "${PLAT}" | jq -c --raw-output '.variant')
		echo "Detected remote: ${PLAT_OS} - ${PLAT_ARCH}"
	done
fi
