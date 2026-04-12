#!/usr/bin/env bash

function hypr_shutdown() {
    local message="$1"
    local cmd="$2"
    hyprshutdown -t "$message" --post-cmd "$cmd"
}

chosen=$(echo -n " Reboot| Lock| Logout| Shutdown| Bios| Cancel" | rofi -sep '|' -dmenu -case-smart -sort -sorting-method fzf -p "")

case $chosen in
    *Reboot*) hypr_shutdown 'Restarting...' 'systemctl reboot';;
    *Lock*) loginctl lock-session;;
    *Logout*) hypr_shutdown "Logging out" "hypectl dispatch exit";;
    *Shutdown*) hypr_shutdown 'Shutting down...' 'systemctl poweroff';;
    *Bios*) hypr_shutdown 'Restarting to bios...' 'systemctl reboot --firmware-setup';;
    *) echo "none" && exit 0;;
esac