#!/usr/bin/with-contenv bash
if [[ -z "${SET_PORT}" ]]; then
	exit 0
fi
if [[ -n "${SET_URLBASE}" ]]; then
	/usr/bin/curl -f http://localhost:${SET_PORT}/${SET_URLBASE}
else
	/usr/bin/curl -f http://localhost:${SET_PORT}/
fi
exit $?
