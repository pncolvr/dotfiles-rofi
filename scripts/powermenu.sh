#!/usr/bin/env bash

function handle_logout() {
    hyprctl dispatch exit
}

chosen=$(echo -n " Reboot| Lock| Logout| Shutdown| Bios| Cancel" | rofi -sep '|' -dmenu -case-smart -sort -sorting-method fzf -p "")

case $chosen in
    *Reboot*) systemctl reboot;;
    *Lock*) loginctl lock-session;;
    *Logout*) handle_logout;;
    *Shutdown*) systemctl poweroff;;
    *Bios*) systemctl reboot --firmware-setup;;
    *) echo "none" && exit 0;;
esac