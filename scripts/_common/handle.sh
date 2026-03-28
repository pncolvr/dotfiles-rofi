#!/usr/bin/env bash

WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname)
source "$WORKSPACE"/utils.sh

load_assoc_array "links" "$1"
keys=$(get_array_keys "links")
# shellcheck disable=2154
if [[ ${#links[@]} -gt 1 ]]; then
    chosen=$(printf '%s\n' "${keys[@]}" | sort | rofi -dmenu -case-smart -sort -sorting-method fzf -p "")
    # chosen=$(printf '%s\n' "${keys[@]}" | sort | rofi -dmenu -case-smart -sort -sorting-method fzf -p "$2")
else 
    chosen="${keys[0]}"
fi
action="$3"
allow_typed="$4"
if [[ -n "$chosen" ]]; then
    picked="${links[$chosen]}"
    if [[ -n "$picked" ]]; then 
        case $action in
            output) echo "$picked";;
            default|*)  open_url "$picked";;
        esac
    else 
        if [[ $allow_typed == true ]]; then
            open_url "$chosen"
        fi
    fi
fi