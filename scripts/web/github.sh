#!/usr/bin/env bash

WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

PROJECT_JSON="${XDG_CACHE_HOME:-$HOME/.cache}/code_projects_${USER}.json"
TEMPLATE_JSON='{
    "prompt": "",
    "action": "default",
    "allowTyped": false,
    "sort": true
}'

function get_projects_urls() {
  local ignoredCategory="${1:-}"

  if [[ -z "$ignoredCategory" ]]; then
    jq '[.[] | select(.url != null) | {url}]' "$PROJECT_JSON" | jq 'unique_by(.url)'
    return
  fi

  jq --compact-output --arg ignoredCategory "$ignoredCategory" \
     '[.[] | select(.category != $ignoredCategory and .url != null) | {url}]' "$PROJECT_JSON" | jq 'unique_by(.url)'
}


if [[ ! -f "$PROJECT_JSON" ]]; then
    echo "Projects JSON file not found: $PROJECT_JSON" >&2
    exit 1
fi

links_file=$(get_temp_file_named $(basename "$0"))
items_json=$(jq 'map({title: (.url | split("/") | last), result: .url})' < <(get_projects_urls $1))

final_json=$(jq -n --argjson items "$items_json" --argjson template "$TEMPLATE_JSON" '$template + {items: $items}')

echo "$final_json" > "$links_file"

"$WORKSPACE"/handle.sh "$links_file"