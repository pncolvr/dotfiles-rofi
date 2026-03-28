#!/usr/bin/env bash

WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

function trim_without_qute() {
    local s="$1"
    # Remove the literal token
    s=${s//\{qutebrowser-webapp\}/}
    # Trim leading whitespace
    s=${s#"${s%%[![:space:]]*}"}
    # Trim trailing whitespace
    s=${s%"${s##*[![:space:]]}"}
    printf '%s\n' "$s"
}

links=$(realpath $(get_env_file $0))
selection=$("$WORKSPACE"/handle.sh "$links" "" "output" )

if [[ "$selection" == "{qutebrowser-webapp}"* ]]; then
    qutebrowser --desktop-file-name qutebrowser-webapp \
        --target window \
        -C ~/.config/qutebrowser/config.py \
        -B ~/.local/share/qutebrowser-webapp \
        "$(trim_without_qute "$selection")" > /dev/null 2>&1 & disown
else
    eval "$selection"
fi