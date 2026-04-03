#!/usr/bin/env bash

projects="${XDG_CACHE_HOME:-$HOME/.cache}/code_projects_${USER}.json"

function pick() {
  rofi -dmenu -case-smart -sort -sorting-method fzf -p ""
}

function pick_path() {
  local ignoredCategory="$1"
  local projectName
  projectName=$(get_project_names "$ignoredCategory" | sort | tr '[:upper:]' '[:lower:]' | pick)
  [ -z "$projectName" ] && exit 0
  
  local workspaces
  workspaces=$(get_workspaces "$projectName")
  if [ "$workspaces" = "[]" ]; then
    get_project_path "$projectName"
  else
    local workspaceNames
    local workspaceName
    workspaceNames=$(jq -r '[.[] | .name] | sort | .[]' <<< "${workspaces[@]}")
    workspaceName=$(printf "%s\nOpen folder\n" "${workspaceNames[@]}" | pick)
    if [ "$workspaceName" = "Open folder" ]; then
      get_project_path "$projectName"
    else 
      jq -r --arg workspaceName "$workspaceName" \
        '.[] | select(.name==$workspaceName) | .path' <<< "${workspaces[@]}"
    fi
  fi
}

function get_project_category_by_path() {
  local path="$1"
  jq -r --arg path "$path" \
    '.[] | select(.rootPath == $path) | .category' "$projects"
}

function get_project_names() {
  local ignoredCategory="${1:-}"

  if [[ -z "$ignoredCategory" ]]; then
    jq -r '.[] | .name' "$projects"
    return
  fi

  jq -r --arg ignoredCategory "$ignoredCategory" \
    '.[] | select(.category != $ignoredCategory) | .name' "$projects"
}

function get_workspaces() {
  get_project_property "$1" "workspaces"
}

function get_project_path() {
  get_project_property "$1" "rootPath"
}

function get_project_property() {
  local projectName="$1"
  local property="$2"
  jq -r --arg projectName "$projectName" --arg property "$property" \
    '.[] | select((.name | ascii_downcase) == ($projectName | ascii_downcase)) | .[$property]' "$projects"
}

function get_friendly_name() {
  local path="$1"
  if [ -d "$path" ]; then
      basename "$path"
  else
      echo "$path" | xargs realpath | xargs dirname | xargs basename
  fi
}

function get_window_address() {
  hyprctl clients -j | \
   jq -r --arg title "$1" \
    '[.[] | select(.class=="code" and (.title | startswith($title)))] | .[0].address // ""'
}

function focus_window() {
  hyprctl dispatch focuswindow "address:$1"
}

function open_editor() {
  local path="$1"
  local profile="${2^}"
  hyprctl dispatch focuswindow class:code
  code "$1" --profile "$profile" & disown
}

function main() {
  local ignoredCategory="${1:-}"
  local path
  local friendlyName
  local windowAddress
  path=$(pick_path "$ignoredCategory")

  [[ -z "$path" ]] && exit 0
  friendlyName=$(get_friendly_name "$path")
  windowAddress=$(get_window_address "$friendlyName")

  if [[ -n "$windowAddress" ]]; then
    focus_window "$windowAddress"
  else
    local category
    category=$(get_project_category_by_path "$path")
    open_editor "$path" "$category"
  fi
}

main "$@"