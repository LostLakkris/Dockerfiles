#!/bin/bash
source /tmp/lakkris.env

while [[ ! -e /var/run/s6/services/inotifyd ]]; do
	sleep 1s
done

s6-svc -wU -u /var/run/s6/services/inotifyd
s6-svwait -u /var/run/s6/services/inotifyd
