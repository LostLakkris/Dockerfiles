#!/bin/bash
CATEGORIES='["Other","Tools","Maintenance"]'
VOLUMES='[{"container": "/var/run/docker.sock","bind": "/var/run/docker.sock"}]'
jq \
	-n \
	-c --raw-output \
	--arg title "autoheal" \
	--arg name "autoheal" \
	--arg description "Simple container to restart others that fail the basic Docker healthcheck function." \
	--arg logo "" \
	--arg image "lostlakkris/autoheal:latest" \
	--arg note "" \
	--argjson categories "${CATEGORIES}" \
	--arg platform "linux" \
	--arg restart_policy "unless-stopped" \
	--argjson volumes "${VOLUMES}" \
	'.type=1|.title=$title|.name=$name|.description=$description|.logo=$logo|.image=$image|.note=$note|.categories=$categories|.platform=$platform|.restart_polcicy=$restart_policy|.volumes=$volumes'
