#!/usr/bin/env bash

WORKSPACE=$(echo "${BASH_SOURCE[0]:-0}" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

list_windows "$(hyprctl activeworkspace -j | jq --raw-output '.id')"