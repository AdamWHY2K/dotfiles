#!/usr/bin/env bash
STATE="/tmp/sway_sp_last"
TREE=$(swaymsg -t get_tree)
FOCUSED=$(echo "$TREE" | jq '.. | objects | select(.focused==true) | .id')

# Floating window visible then hide it and remember
if echo "$TREE" | jq -e ".. | objects | select(.id==$FOCUSED and .floating==\"user_on\")" > /dev/null; then
    echo "$FOCUSED" > "$STATE"
    swaymsg "[con_id=$FOCUSED] move scratchpad"
    exit 0
fi

# No floating window visible then show the last hidden one
if [ -f "$STATE" ]; then
    ID=$(cat "$STATE")
    if echo "$TREE" | jq -e ".. | objects | select(.id==$ID)" > /dev/null; then
        swaymsg "[con_id=$ID] move workspace current; [con_id=$ID] focus"
        exit 0
    fi
fi

# Fallback: normal behaviour
swaymsg scratchpad show
