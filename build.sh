#!/bin/bash
set -e
echo "CONTAINER: ${CONTAINER}"
echo "FROM: ${FROM}"
echo "DOCKER_CLI_EXPERIMENTAL: ${DOCKER_CLI_EXPERIMENTAL}"
docker version

docker login -u "${DOCKER_USER}" -p "${DOCKER_PASSWORD}" &> /dev/null

if [[ -n "${FROM}" ]]; then
	echo "== Checking available origin ARCHs"
	PLATFORMS=""
	for PLAT in $(docker manifest inspect "${FROM}" | jq -c --raw-output '.manifests[].platform'); do
		PLAT_OS=$(echo "${PLAT}" | jq -c --raw-output '.os')
		PLAT_ARCH=$(echo "${PLAT}" | jq -c --raw-output '.architecture')
		PLAT_VARIANT=$(echo "${PLAT}" | jq -c --raw-output '.variant')
		echo "Detected remote: ${PLAT_OS} - ${PLAT_ARCH}"
		if [[ -n "${PLATFORMS}" ]]; then
			PLATFORMS+=","
		fi
		PLATFORMS+="${PLAT_OS}/${PLAT_ARCH}"
		if [[ -n "${PLAT_VARIANT}" && "${PLAT_VARIANT}" != "null" ]]; then
			PLATFORMS+="/${PLAT_VARIANT}"
		fi
	done
cat >/tmp/build_environment <<EOL
FROM=${FROM}
CONTAINER=${CONTAINER}
EOL
	templater -f /tmp/build_environment Dockerfile.tmpl > Dockerfile
	docker buildx create --name ${CONTAINER}
	docker buildx use ${CONTAINER}
	docker buildx ls
	docker buildx build --platform "${PLATFORMS}" -t "lostlakkris/${CONTAINER}:latest" --push .
	docker buildx imagetools inspect lostlakkris/${CONTAINER}:latest
	docker manifest inspect lostlakkris/${CONTAINER}
fi
