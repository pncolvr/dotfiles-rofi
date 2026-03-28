#!/usr/bin/env bash

WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

projects_json="${XDG_CACHE_HOME:-$HOME/.cache}/code_projects_${USER}.json"

function get_projects_urls() {
  local ignoredCategory="${1:-}"

  if [[ -z "$ignoredCategory" ]]; then
    jq -r '.[] | .url' "$projects_json"
    return
  fi

  jq -r --arg ignoredCategory "$ignoredCategory" \
    '.[] | select(.category != $ignoredCategory) | .url' "$projects_json"
}

declare -A menu_items=()

if [[ ! -f "$projects_json" ]]; then
    echo "Projects JSON file not found: $projects_json" >&2
    exit 1
fi

while IFS= read -r git_url; do
    repo_path="$(basename "$git_url")"
    menu_items+=(["$repo_path"]="$git_url")
done < <(get_projects_urls $1 | sort -u)

linksFile=$(get_temp_file_named $( basename "$0"))
save_assoc_array "menu_items" "$linksFile"

"$WORKSPACE"/handle.sh "$linksFile" "github"