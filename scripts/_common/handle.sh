#!/usr/bin/env bash

WORKSPACE=$(echo "${BASH_SOURCE[0]:-0}" | xargs realpath | xargs dirname)
source "$WORKSPACE"/utils.sh

FILE="$1"

function handle_sort() {
    [[ "$SORT" == false ]] && cat || sort
}

IFS=';' read PROMPT ACTION ALLOW_TYPED SORT <<< "$(jq -r ' [ .prompt, .action, .allowTyped, .sort ] | join(";")' "$FILE")"

mapfile -t keys < <(jq -r '.items[] | .title' "$FILE")

if [[ ${#keys[@]} -gt 1 ]]; then
    chosen=$(printf '%s\n' "${keys[@]}" | handle_sort | rofi -dmenu -no-sort -case-smart -p "$PROMPT")
    # chosen=$(printf '%s\n' "${keys[@]}" | handle_sort | rofi -dmenu -case-smart -sort -sorting-method fzf -p "$PROMPT")
else
    chosen="${keys[0]}"
fi

if [[ -n "$chosen" ]]; then
    picked=$(jq -r --arg title "$chosen" '.items[] | select(.title==$title) | .result' "$FILE" )
    if [[ -n "$picked" ]]; then
        case $ACTION in
            output) echo "$picked";;
            default|*)  open_url "$picked";;
        esac
    else
        if [[ $ALLOW_TYPED == true ]]; then
            open_url "$chosen"
        fi
    fi
fi