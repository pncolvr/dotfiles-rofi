#!/usr/bin/env bash

WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

links=$(realpath $(get_env_file $0))
selection=$("$WORKSPACE"/handle.sh "$links" )

IFS=';' read action url <<< "$(jq -r '[.action, .url] | join(";")' <<< $selection)"

if [[ "$action" == "qutebrowser-webapp" ]]; then
    qutebrowser --desktop-file-name qutebrowser-webapp \
        --target window \
        -C ~/.config/qutebrowser/config.py \
        -B ~/.local/share/qutebrowser-webapp \
        "$url" > /dev/null 2>&1 & disown
else
    eval "$action $url"
fi