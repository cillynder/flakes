#!/usr/bin/env sh

get_title () {
    niri msg --json windows | jq -r ".[] | select(.id == $1) | .title"
}

out () {
    if [ ! -z "$1" ] && [ "$1" != "null" ]; then
        echo "(box :class \"widget title\" :halign \"center\" :valign \"center\" :vexpand true :hexpand true (label :text \"$1\"))"
    fi
}

last_id=-1

niri msg --json event-stream | while read -r line; do
    sn=$(echo $line | jq '.WorkspaceActiveWindowChanged.active_window_id')
    if [ ! -z "$sn" ] && [ "$sn" != "null" ]; then
        last_id=$sn
        tt=$(get_title $last_id)
    fi

    sn=$(echo $line | jq '.WindowFocusChanged.id')
    if [ ! -z "$sn" ] && [ "$sn" != "null" ]; then
        last_id=$sn
        tt=$(get_title $last_id)
    fi

    sn=$(echo $line | jq -r ".WindowOpenedOrChanged.window | select(.id == $last_id) | .title")
    if [ ! -z "$sn" ] && [ "$sn" != "null" ]; then
        tt="$sn"
    fi

    out "$tt"
done

