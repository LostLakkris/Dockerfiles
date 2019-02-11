#!/bin/bash
if [[ -d /var/run/s6/services/inotifyd ]]; then
	s6-svc -wr -r /var/run/s6/services/inotifyd
fi
