#!/bin/bash
# Usage: sway-quiet <window_criteria> <command> [args...]
#   window_criteria: a grep pattern that matches the window in `swaymsg -t get_tree`
# Example: sway-quiet 'class.*steam' steam
#          sway-quiet 'app_id.*discord' discord

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <criteria_pattern> <command> [args...]" >&2
    exit 1
fi

pattern="$1"
shift
cmd="$@"

# Save current activation setting
old_setting=$(swaymsg -t get_config | grep '^focus_on_window_activation' | awk '{print $2}')
[ -z "$old_setting" ] && old_setting="urgent"

# Block focus stealing temporarily
swaymsg "focus_on_window_activation none"

# Launch the application
$cmd &

# Wait for a window matching the pattern to appear (with timeout)
timeout=10
elapsed=0
while [ $elapsed -lt $timeout ]; do
    if swaymsg -t get_tree | grep -q "$pattern"; then
        break
    fi
    sleep 0.2
    elapsed=$((elapsed + 1))
done

# Restore original setting
swaymsg "focus_on_window_activation $old_setting"
