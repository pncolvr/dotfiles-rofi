#!/usr/bin/env bash

WORKSPACE=$(dirname "${BASH_SOURCE[0]:-0}")
source "$WORKSPACE"/../_common/utils.sh

list_windows "$(hyprctl activeworkspace -j | jq --raw-output '.id')"