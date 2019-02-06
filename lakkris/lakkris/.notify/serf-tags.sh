#!/bin/bash
event="${1}"
object="${2}"


ENV_FILE=/tmp/lakkris.env
TAG_FILE=/etc/serf/tags.json
#s6-svwait -u /var/run/s6/services/serf
#if [[ $(s6-svstat -u "/var/run/s6/services/serf") == "true" ]]; then
#	TAG_SET=$(awk '{print $2}' ${ENV_FILE} | sed ':a;N;$!ba;s/\n/ -set /g')
#	eval "serf tags -set ${TAG_SET}"
#fi

s6-svc -wU -u /var/run/s6/services/serf
s6-svwait -u /var/run/s6/services/serf
HASH_START=$(md5sum ${TAG_FILE} | awk '{print $1}')
if [[ -e ${ENV_FILE} ]]; then
	cat /tmp/lakkris.env | cut -d' ' -f2- | jq --raw-input --slurp '[split("\n") | map(select(. != ""))[] | split("=")] | map({(.[0]): .[1] }) | add | {"tags": .}' > ${TAG_FILE}
fi
HASH_END=$(md5sum ${TAG_FILE} | awk '{print $1}')
if [[ $(s6-svstat -u "/var/run/s6/services/serf") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/serf"
fi
