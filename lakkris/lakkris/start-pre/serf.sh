#!/bin/bash
source /tmp/lakkris.env

if [[ ! -d /etc/serf ]]; then
	mkdir /etc/serf
fi

# INOTIFY DATA
# Anytime lakkris environment has updated, rebuild the tags and rescan the config directory
NOTIFY=(
	'/tmp/lakkris.env:c,/lakkris/events-notify/serf.sh'
	'/tmp/lakkris.env:x,/lakkris/events-notify/serf.sh'
)
for entry in ${NOTIFY[@]}; do
	if ! grep -q "^${entry%,*}" "/tmp/lakkris.notify"; then
		echo "${entry}" >> /tmp/lakkris.notify
	fi
done

HASH_START=$(md5sum /etc/serf/* | sort -n | md5sum | awk '{print $1}')
# Set binding config
jq -n \
  --arg bind "${LAKKRIS_IP}:7946" \
  --arg interface "${LAKKRIS_IFACE}" \
  '.bind=$bind|.profile="wan"' > /etc/serf/bind.json
#  '.bind=$bind|.interface=$interface|.profile="wan"|.snapshot_path="/config/serf"|.rejoin_after_leave=true' > /etc/serf/bind.json

#jq -n \
#  '.snapshot_path="/config/serf"|.rejoin_after_leave=true' > /etc/serf/snapshots.json

if [[ -x "${LAKKRIS_HANDLER:-/lakkris/handlers/serf.sh}" ]]; then
jq -n \
  --arg handler "${LAKKRIS_HANDLER:-/lakkris/handlers/serf.sh}" \
  '{"event_handlers":[]} | .event_handlers |= . + [$handler]' > /etc/serf/event_handler.json
fi

# Set the mdns
jq -n \
  --arg mdns "${LAKKRIS_MDNS:-lakkris}" \
  '.discover=$mdns' > /etc/serf/discover.json

# Make up a hostname to prevent collusions... Since weave overrides the container's hostname
jq -n \
  --arg name "$(echo "${LAKKRIS_IP}__${LAKKRIS_HOSTNAME}" | md5sum | awk '{print $1}' | head -c 12)" \
  '.node_name=$name' > /etc/serf/nodename.json

# Set all the tags
cat /tmp/lakkris.env | cut -d' ' -f2- | sort | jq --raw-input --slurp '[split("\n") | map(select(. != ""))[] | split("=")] | map({(.[0]): .[1] }) | add | {"tags": .}' > /etc/serf/tags.json

HASH_END=$(md5sum /etc/serf/* | sort -n | md5sum | awk '{print $1}')
if [[ -d "/var/run/s6/services/serf" && $(s6-svstat -u "/var/run/s6/services/serf") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/serf"
fi
