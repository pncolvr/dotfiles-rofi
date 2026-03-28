#!/usr/bin/env bash

# TODO: move this script out of here

TEMP_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"

function notify_waybar () {
    echo "$2" > "$TEMP_DIR/${1}_status"
}

function monitor_virtual_machine() {
    local server=$1
    local port=$2
    local name=$3
    local max_attempts=60
    attempt=1
    notify_waybar "$name" "booting"
    while (( attempt <= max_attempts )); do
        if nc -z "$server" "$port" 2>/dev/null; then
            notify_waybar "$name" "booted"
            break
        else
            (( attempt++ ))
            sleep 1
        fi
    done
    [[ $attempt == "$max_attempts" ]] && notify_waybar "$name" "error"
}

function toggle_virtual_machine() {
    local name=$1
    local status
    status=$(virsh -c qemu:///system list | grep "$name" | awk '{ print $3 }')
    if [[ "$status" == "running" ]]; then
        stop_virtual_machine "$name"
    else
        start_virtual_machine "$name"
    fi
}

function start_virtual_machine() {
    local name=$1
    virsh -c qemu:///system start "$name" >> /dev/null 2>&1
}

function stop_virtual_machine() {
    local name=$1
    virsh -c qemu:///system shutdown "$name"
    notify_waybar "$name" "stopping" 
}