#!/bin/bash
source /tmp/lakkris.env

if [[ ! -d /etc/serf ]]; then
	mkdir /etc/serf
fi

# INOTIFY DATA
# Anytime lakkris environment has updated, rebuild the tags and rescan the config directory
if ! grep -q "^/tmp/lakkris.env:c" "/tmp/lakkris.notify"; then
	echo "/tmp/lakkris.env:c,/lakkris/events-notify/serf.sh" >> /tmp/lakkris.notify
fi

# Try to figure out the proper IP address for binding
if [[ -z "${BIND}" && -e /sbin/ip ]]; then
        BIND=$(/sbin/ip addr show ${LAKKRIS_IFACE} | awk '/inet/{print $2}' | cut -d'/' -f1)
fi
if [[ -z "${BIND}" && -e /bin/networkctl ]]; then
        BIND=$(/bin/networkctl status ${LAKKRIS_IFACE} | awk '$1 ~ "Address"{print $2}')
fi
if [[ -z "${BIND}" ]]; then
        BIND=$(hostname -i)
fi

HASH_START=$(md5sum /etc/serf/* | sort -n | md5sum | awk '{print $1}')
# Set binding config
jq -n \
  --arg bind "${BIND}:7946" \
  --arg interface "${LAKKRIS_IFACE}" \
  '.bind=$bind|.profile="wan"|.snapshot_path="/config/serf"|.rejoin_after_leave=true' > /etc/serf/bind.json
#  '.bind=$bind|.interface=$interface|.profile="wan"|.snapshot_path="/config/serf"|.rejoin_after_leave=true' > /etc/serf/bind.json

if [[ -x "${LAKKRIS_HANDLER:-'/lakkris/handlers/serf.sh'}" ]]; then
jq -n \
  --arg handler "${LAKKRIS_HANDLER:-'/lakkris/handlers/serf.sh'}" \
  '{"event_handlers":[]} | .event_handlers |= . + [$handler]' > /etc/serf/event_handler.json
fi

# Set the mdns
jq -n \
  --arg mdns "${LAKKRIS_MDNS:-lakkris}" \
  '.discover=$mdns' > /etc/serf/discover.json

# Set all the tags
cat /tmp/lakkris.env | cut -d' ' -f2- | sort | jq --raw-input --slurp '[split("\n") | map(select(. != ""))[] | split("=")] | map({(.[0]): .[1] }) | add | {"tags": .}' > /etc/serf/tags.json

HASH_END=$(md5sum /etc/serf/* | sort -n | md5sum | awk '{print $1}')
if [[ -d "/var/run/s6/services/serf" && $(s6-svstat -u "/var/run/s6/services/serf") == "true" && "${HASH_START}" != "${HASH_END}" ]]; then
	s6-svc -h "/var/run/s6/services/serf"
fi
