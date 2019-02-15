#!/bin/bash
HASH_START=$(md5sum "/etc/serf/tags.json" | awk '{print $1}')
cat /tmp/lakkris.env | cut -d' ' -f2- | sort | jq --raw-input --slurp '[split("\n") | map(select(. != ""))[] | split("=")] | map({(.[0]): .[1] }) | add | {"tags": .}' > /etc/serf/tags.json
HASH_END=$(md5sum "/etc/serf/tags.json" | awk '{print $1}')
if [[ -d "/var/run/s6/services/serf" && $(s6-svstat -u "/var/run/s6/services/serf") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
                s6-svc -h "/var/run/s6/services/serf"
fi
