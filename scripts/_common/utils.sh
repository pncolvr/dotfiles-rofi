#!/usr/bin/env bash

function open_url() {
    "$ZDOTDIR"/scripts/default-browser/default-browser.sh "$@"
}

function get_temp_dir() {
    echo "${XDG_RUNTIME_DIR:-/tmp}"
}

function get_temp_file_named() {
  local name=$1
  echo "$(get_temp_dir)/${name}_$(id -u)"
}

function get_env_file() {
    local path=$1
    local filename=$(basename "$path")
    filename="${filename%.*}"
    echo "$(dirname "$path")/$filename.env"
}

function log() {
    _internal_log 7 "$@"
}

function log_error() {
    _internal_log 4 "$@"
}

function _internal_log() {
    local priority
    local emitError
    priority=$1
    shift
    if [ -n "$1" ]; then
        IN="$1"
    else
        read IN
    fi
    case $priority in
        1|2|3|4) emitError="--stderr";;
        5|6|7) emitError="";;
    esac
    logger "$emitError" --priority "$priority" --tag $(basename "${BASH_SOURCE[0]:-0}") $IN
}


function handle_title() {
    local workspace="$1" class="$2" title="$3"
    local label=""
    case $workspace in
        4) label=$(handle_workspace_4_title "$class" "$title");;
        *) label="$(printf '%s' "$title" | cut -c -100)";;
    esac
    echo "$workspace $class: $label"
}

function handle_workspace_4_title(){
    class=$1
    windowTitle=$2
    if [[ "$class" == "code" ]]; then
        line="${windowTitle%-●}"
        IFS='-' read -r first _ last <<< "$line"
        if [[ -n "$last" ]]; then
            echo "$first ($last)"
        else
            echo "$first"
        fi
    else
        echo "$windowTitle"
    fi
}

function get_windows() {
  local ws=$1
  hyprctl clients -j | jq -r --arg ws "$ws" --argjson f false '
    map(select(($ws|length)==0 or (.workspace.id == ($ws|tonumber?) and .floating == $f)))
    | sort_by(.focusHistoryID // 0) | reverse
    | map([
        .address,
        (.workspace.name // ""),
        (.class // ""),
        (.title // "")
      ])
    | .[]
    | @tsv'
}

function list_windows() {
  while true; do
    windows=$(get_windows "$1")
    if [[ -z $windows ]]; then
      count=0
    else
      count=$(printf '%s\n' "$windows" | wc -l)
    fi
    
    if [[ $count -lt 2 ]]; then
      windows=$(get_windows)
    fi

    addresses=()
    display=()

    while IFS=$'\t' read -r addr workspace class title; do
      [ -n "$addr" ] || continue
      addresses+=("$addr")
      display+=("$(handle_title "$workspace" "$class" "$title")")
    done <<< "$windows"
    if [[ $count -eq 2 ]]; then
        keycode=0
        index=0
    else 
      selection=$(printf '%s\n' "${display[@]}" | rofi  -dmenu -case-smart -sort -sorting-method fzf -p "" -kb-accept-custom '' -kb-custom-1 'Control+Return')
      keycode=$?
      
      [ -z "$selection" ] && exit 0

      index=-1
      for i in "${!display[@]}"; do
        if [[ "${display[$i]}" == "$selection" ]]; then
          index="$i"
          break
        fi
      done
    fi
    

    case "$keycode" in
      0) [ "$index" -ge 0 ] && hyprctl dispatch focuswindow "address:${addresses[$index]}" && exit 0;;
      10)[ "$index" -ge 0 ] && hyprctl dispatch closewindow "address:${addresses[$index]}";;
    esac
    sleep 0.1
    pkill -RTMIN+1 waybar # send event to the custom windows module to update itself
  done 
}

function get_ignored_category() {
  local status
  status=$($ZDOTDIR/scripts/status/manager.sh --get)
  if [[ "$status" != "$WORKING_STATE_NAME" ]]; then
    echo -n "$WORKING_STATE_NAME"
  else 
    echo -n ""
  fi
}

source "$(get_env_file ${BASH_SOURCE[0]:-0})"