#!/usr/bin/env bash

function open_manga() {
    if ! pgrep manga-tui >/dev/null; then
        kitty --class kitty-manga -e 'manga-tui' & disown
    fi
}

hyprctl dispatch workspace 2
chosen=$(echo "continue|search|manga" | rofi -sep '|' -dmenu -i -p "")
# chosen=$(echo "continue|search|manga" | rofi -sep '|' -dmenu -i -p ani-cli)
case $chosen in
    *search*) ani-cli --rofi;;
    *continue*) ani-cli -c --rofi;;
    *manga*) open_manga;;
    *)exit 0;;
esac