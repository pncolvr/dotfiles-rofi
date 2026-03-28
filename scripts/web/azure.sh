#!/usr/bin/env bash

filename=$(echo "${0%.*}" | xargs basename)
WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common

source "$WORKSPACE"/utils.sh

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/azure_${USER}"

build_cache() {
    echo "Building cache..."
    
    # Start Azure tools container and get subscription data
    podman run -d --replace --name azure-tools \
        -v azure-tools-azure:/home/vscode/.azure \
        -v "/home/pncolvr/Projects/scripts/azure/updateip":/workspaces/scripts/azure/updateip \
        -w /workspaces/scripts/azure/updateip \
        --restart=unless-stopped \
        updateip:latest sleep infinity

    # Get JSON output and parse into associative array
    json_output=$(podman exec -it azure-tools /workspaces/scripts/azure/updateip/scripts/list-subs.sh | sed -n '/^\[/,$p' | tr -d '\r')

    declare -A links
    # Use jq to properly parse JSON and extract name-id pairs
    while IFS=$'\t' read -r name id; do
        if [[ -n "$name" && -n "$id" ]]; then
            links["$name"]="$id"
        fi
    done < <(echo "$json_output" | jq -r '.[] | [.name, .id] | @tsv')

    # Convert subscription IDs to Azure portal URLs
    for key in "${!links[@]}"; do
        links["$key"]="https://portal.azure.com/#@teambizdocs.onmicrosoft.com/resource/subscriptions/${links[$key]}/resources"
        echo "Found subscription '$key'"
    done

    save_assoc_array "links" "$CACHE_FILE"
    echo "Cache saved: $CACHE_FILE"
}

rebuild_cache=false
pick=false
for arg in "$@"; do
    case "$arg" in
        --rebuild-cache)
            rebuild_cache=true
            ;;
        --pick)
            pick=true
            ;;
    esac
done

if $rebuild_cache; then
    build_cache
fi

if $pick; then
    if [[ ! -f "$CACHE_FILE" ]]; then
        build_cache
    fi
    
    "$WORKSPACE"/handle.sh "$CACHE_FILE" ""
fi