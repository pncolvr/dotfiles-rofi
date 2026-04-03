#!/usr/bin/env bash
WORKSPACE=$(echo "${BASH_SOURCE[0]:-0}" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh
# shellcheck disable=2119
list_windows