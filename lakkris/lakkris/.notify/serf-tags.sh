#!/bin/bash
event="${1}"
object="${2}"


ENV_FILE=/tmp/lakkris.env
if [[ $(s6-svstat -u "/var/run/s6/services/serf") ]]; then
	TAG_SET=$(awk '{print $2}' ${ENV_FILE} | sed ':a;N;$!ba;s/\n/ -set /g')
	eval "serf tags -set ${TAG_SET}"
fi
