#!/usr/bin/env bash

WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

list_windows "$(hyprctl activeworkspace -j | jq --raw-output '.id')"