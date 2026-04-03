#!/usr/bin/env bash

WORKSPACE=$(echo "${BASH_SOURCE[0]:-0}" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

links=$(realpath $(get_env_file ${BASH_SOURCE[0]:-0}))
selection=$("$WORKSPACE"/handle.sh "$links" )

IFS=';' read action url <<< "$(jq -r '[.action, .url] | join(";")' <<< $selection)"

if [[ -z "$action" || -z "$url" ]]; then
    exit
fi

case "$action" in
    "qutebrowser-webapp")
        url="$action $url" 
        ;;
esac

$HOME/Projects/scripts/default-browser/default-browser.sh $(printf '%s' "$url")