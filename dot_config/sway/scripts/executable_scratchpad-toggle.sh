#!/usr/bin/env bash
STATE="/tmp/sway_sp_last"
TREE=$(swaymsg -t get_tree)
FOCUSED=$(echo "$TREE" | jq '.. | objects | select(.focused==true) | .id')

id_exists() {
    echo "$TREE" | jq -e ".. | objects | select(.id==$1)" > /dev/null 2>&1
}

# Find whatever scratchpad window is currently visible, if any.
VISIBLE=$(echo "$TREE" | jq -r '
  .. | objects | select(.type=="workspace" and .name!="__i3_scratch")
  | .floating_nodes[]? | select(.scratchpad_state!="none") | .id' | head -n1)

if [ -n "$VISIBLE" ]; then
    echo "$VISIBLE" > "$STATE"
    if [ "$VISIBLE" = "$FOCUSED" ]; then
        swaymsg "[con_id=$VISIBLE] move scratchpad"
    else
        swaymsg "[con_id=$VISIBLE] focus"
    fi
    exit 0
fi

# Nothing is visible. Restore the last one this script hid, if it still exists.
ID=""
[ -f "$STATE" ] && ID=$(cat "$STATE")

if [ -n "$ID" ] && id_exists "$ID"; then
    swaymsg "[con_id=$ID] move workspace current; [con_id=$ID] focus"
    exit 0
fi

# No stored window, or it is gone. Let sway pick one, then record it.
swaymsg scratchpad show > /dev/null
NEW_ID=$(swaymsg -t get_tree | jq -r '
  .. | objects | select(.type=="workspace" and .name!="__i3_scratch")
  | .floating_nodes[]? | select(.scratchpad_state!="none") | .id' | head -n1)
[ -n "$NEW_ID" ] && echo "$NEW_ID" > "$STATE"
