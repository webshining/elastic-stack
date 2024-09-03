#!/usr/bin/env bash

# --- functions ---
wait_elasticsearch() {

	local -a args=('-s' '-w' '%{http_code}' '-o' '/dev/null'
        'http://elasticsearch:9200/'
        '-u' "elastic:${ELASTIC_PASSWORD:-changeme}"
    )

	local -i result=1
	local output

	for _ in $(seq 1 60); do
		local -i exit_code=0
		output="$(curl "${args[@]}")" || exit_code=$?

		if ((exit_code)); then
			result=$exit_code
		fi

		if [[ "$output" -eq 200 ]]; then
			result=0
			break
		fi

		sleep 3
	done

    return $result
}

change_password() {
    local name=$1
    local password=$2
    
    local -a args=('-s' '-w' '%{http_code}' '-o' '/dev/null'
        "http://elasticsearch:9200/_security/user/${name}/_password"
        '-X' 'POST'
        '-H' 'Content-Type: application/json'
        '-d' "{\"password\": \"$password\"}"
        '-u' "elastic:${ELASTIC_PASSWORD:-changeme}"
    )

    if [[ "$(curl "${args[@]}")" -eq 200 ]]; then
        return 0
    else
        return 1
    fi
}

is_user_exists() {
    local name=$1

	local -a args=( '-s' '-w' '%{http_code}' '-o' '/dev/null'
		"http://elasticsearch:9200/_security/user/$name"
        '-u' "elastic:${ELASTIC_PASSWORD:-changeme}"
    )

	local -i result=1
    local -i exists=0

    if [[ "$(curl "${args[@]}")" -eq 200 ]]; then
		result=0
		exists=1
	fi

	echo "$exists"
	return $result
}


log() {
	echo "[+] $1"
}

sublog() {
	echo -e "\t\t[-] $1"
}

suberr() {
	echo -e "\t\t[x]$1" >&2
}