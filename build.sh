#!/bin/bash
set -e
echo "CONTAINER: ${CONTAINER}"

docker login -u "${DOCKER_USER}" -p "${DOCKER_PASSWORD}" &> /dev/null

DOCKERFILE="Dockerfile.${CONTAINER}"

if [[ -e "Dockerfiles/${DOCKERFILE}" ]]; then
	echo "== Checking available origin ARCHs"
	FROM=$(awk '/^FROM/{print $NF}' "Dockerfiles/${DOCKERFILE}")

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

	if [[ -z "${PLATFORMS}" ]]; then
		PLATFORMS="linux/amd64"
	fi
	docker buildx create --name ${CONTAINER}
	docker buildx use ${CONTAINER}
	docker buildx ls
	docker buildx build --platform "${PLATFORMS}" -t "lostlakkris/${CONTAINER}:latest" --push -f "Dockerfiles/${DOCKERFILE}" .
	docker buildx imagetools inspect lostlakkris/${CONTAINER}:latest
	docker manifest inspect lostlakkris/${CONTAINER}
fi
