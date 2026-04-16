#!/usr/bin/env bash

WORKSPACE=$(dirname "${BASH_SOURCE[0]:-0}")
source "$WORKSPACE"/utils.sh

FILE="$1"

function handle_sort() {
    [[ "$SORT" == false ]] && cat || sort
}

function handle() {
    local picked="$1"
    case $ACTION in
        output) echo "$picked";;
        default|*) open_url "$picked";;
    esac
}

IFS=';' read PROMPT ACTION ALLOW_TYPED ALLOW_MULTIPLE_SELECTION SORT <<< "$(jq -r ' [ .prompt, .action, .allowTyped, .allowMultipleSelection, .sort ] | join(";")' "$FILE")"

mapfile -t keys < <(jq -r '.items[] | .title' "$FILE")

if [[ ${#keys[@]} -gt 1 ]]; then
    ROFI_ARGS="-dmenu -case-smart"
    if [[ "$ALLOW_MULTIPLE_SELECTION" == "true" ]]; then
        ROFI_ARGS+=" -multi-select"
    fi
    
    chosen=$(printf '%s\n' "${keys[@]}" | handle_sort | rofi $ROFI_ARGS -p "$PROMPT")
else
    chosen="${keys[0]}"
fi

if [[ -n "$chosen" ]]; then
    while IFS= read -r title; do
        picked=$(jq -r --arg title "$title" '.items[] | select(.title==$title) | .result' "$FILE" )
        if [[ -n "$picked" ]]; then
            handle "$picked"
        fi
    done <<< "$chosen"

    if [[ -z "$picked" && $ALLOW_TYPED == true ]]; then
        handle "$chosen"
    fi
fi