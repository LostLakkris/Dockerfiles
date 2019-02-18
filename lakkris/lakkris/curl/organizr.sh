#!/bin/bash
OIFS=$IFS
IFS=$'\n'
source /tmp/lakkris.env
if [[ -z "${LAKKRIS_PORT}" ]]; then
	echo "PORT not configured."
	exit 1
fi

if [[ -e "/config/www/Dashboard/api/config/config.php" ]]; then
	LAKKRIS_APITOKEN=$(awk '/organizrAPI/{print $NF}' "/config/www/Dashboard/api/config/config.php" | tr -d "',")
fi

# Defaults
METHOD='GET'
CONTENT_TYPE='application/json'
URI=''
PAYLOAD=''
ARGS=()
URLENCODE=()
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
		"--data")
			URLENCODE+=( "${2}" )
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
	ARGS+=( '--header' "Token: ${LAKKRIS_APITOKEN}" )
fi
if [[ -n "${CONTENT_TYPE}" ]]; then
	ARGS+=( '--header' "Content-Type: ${CONTENT_TYPE}" )
fi
if [[ -n "${PAYLOAD}" && ("${METHOD}" == "POST" || "${METHOD}" == "PUT") ]]; then
	ARGS+=( '-d' "${PAYLOAD}" )
fi
if [[ ${#URLENCODE[@]} -gt 0 ]]; then
	for enc in ${URLENCODE[@]}; do
		ARGS+=( '--data-urlencode' "${enc}" )
	done
fi
URL="http://127.0.0.1:${LAKKRIS_PORT}/api?v1"
ARGS+=( "${URL}/${URI}" )
#(>&2 echo "${ARGS[@]}")
curl ${ARGS[@]}
OIFS=$IFS
