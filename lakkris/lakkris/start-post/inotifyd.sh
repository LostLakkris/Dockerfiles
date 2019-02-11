#!/bin/bash
source /tmp/lakkris.env

while [[ ! -d /var/run/s6/services/inotifyd || ! -s /tmp/lakkris.notify ]]; do
	sleep 1s
done

s6-svc -wu -u /var/run/s6/services/inotifyd
s6-svwait -u /var/run/s6/services/inotifyd
