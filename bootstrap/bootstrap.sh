#!/usr/bin/env bash

set -eu -o pipefail

source /scripts.sh

# --- wait elasticsearch ---
log 'Waiting for availability of Elasticsearch. This can take several minutes.'

declare -i exit_code=0
wait_elasticsearch || exit_code=$?

if ((exit_code)); then
	case $exit_code in
		6)
			suberr 'Could not resolve host. Is Elasticsearch running?'
			;;
		7)
			suberr 'Failed to connect to host. Is Elasticsearch healthy?'
			;;
		28)
			suberr 'Timeout connecting to host. Is Elasticsearch healthy?'
			;;
		*)
			suberr "Connection to Elasticsearch failed. Exit code: $exit_code"
			;;
	esac

	exit $exit_code
fi

# --- data ---
declare -A passwords
passwords=(
    [kibana_system]="${KIBANA_SYSTEM_PASSWORD:-changeme}"
)

# --- main ---
for name in "${!passwords[@]}"; do
	log "user [NAME: $name]"
    if (("$(is_user_exists "$name")")); then
        change_password "$name" "${passwords[$name]}" || exit_code=$?
		if ((exit_code)); then
			continue
		else
			sublog "password successfully set"
		fi
    fi
done
