#!/usr/bin/env bash
WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh
# shellcheck disable=2119
list_windows