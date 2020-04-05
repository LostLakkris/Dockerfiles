#!/bin/sh
set -e
for setupScript in $(ls -1 /setup/*.sh | grep -v '/setup.sh$'); do
	if [[ -x "${setupScript}" ]]; then
		bash ${setupScript}
	fi
done
