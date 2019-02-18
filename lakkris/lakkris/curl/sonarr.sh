#!/bin/bash
OIFS=$IFS
IFS=$'\n'
source /tmp/lakkris.env
if [[ -z "${LAKKRIS_APITOKEN}" || -z "${LAKKRIS_WEBROOT}" || -z "${LAKKRIS_PORT}" ]]; then
	echo "APITOKEN, WEBROOT, or PORT not configured."
	exit 1
fi

# Defaults
METHOD='GET'
CONTENT_TYPE='application/json'
URI=''
PAYLOAD=''
ARGS=()
while [[ -n "${1}" ]]; do
	case "${1}" in
		"-m")
			METHOD="$(echo ${2} | tr '[a-z]' '[A-Z]')"
			shift
			;;
		"-u")
			URI="${2}"
			shift
			;;
		"-p")
			PAYLOAD="${2}"
			shift
			;;
		"-c")
			CONTENT_TYPE="${2}"
			shift
			;;
	esac
	shift
done
if [[ -z "${URI}" ]]; then
	echo "No URI specified"
	exit 1
fi
ARGS+=( '--connect-timeout' '10' '-L' '-s' '-k' '-A' 'lazylakkris' '-X' "${METHOD}" )
if [[ -n "${LAKKRIS_APITOKEN}" ]]; then
	ARGS+=( '--header' "X-Api-Key: ${LAKKRIS_APITOKEN}" )
fi
if [[ -n "${CONTENT_TYPE}" ]]; then
	ARGS+=( '--header' "Content-Type: ${CONTENT_TYPE}" )
fi
if [[ -n "${PAYLOAD}" && ("${METHOD}" == "POST" || "${METHOD}" == "PUT") ]]; then
	ARGS+=( '-d' "${PAYLOAD}" )
fi
URL="http://127.0.0.1:${LAKKRIS_PORT}"
if [[ -n "${LAKKRIS_WEBROOT}" ]]; then
	URL+="/${LAKKRIS_WEBROOT}"
fi
case "${LAKKRIS_SERVICE}" in
	"lidarr")
		ARGS+=( "${URL}/api/v1/${URI}" )
		;;
	*)
		ARGS+=( "${URL}/api/${URI}" )
		;;
esac
#(>&2 echo "${ARGS[@]}")
curl ${ARGS[@]}
OIFS=$IFS
