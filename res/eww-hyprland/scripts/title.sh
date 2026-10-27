#!/usr/bin/env sh

out () {
    if [ -z "$1" ] || [ "$1" == "null" ]; then
        echo ""
    else
        echo "(box :class \"widget title\" :halign \"center\" :valign \"center\" :vexpand true :hexpand true (label :text \"$1\"))"
    fi
}

init=$(hyprctl activewindow -j | jq --raw-output .title)
trunc=$(echo $init | cut -c-60)
out "$trunc"

socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | stdbuf -o0 awk -F '>>|,' '/^activewindow>>/{print $3}' | while read -r line ; do
    trunc=$(echo $line | cut -c-60)
    out "$trunc"
done
