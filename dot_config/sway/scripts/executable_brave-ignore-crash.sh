#!/bin/bash
# Force Brave to restore last session once, then relaunch normally if it crashes quickly.

set -euo pipefail
PREF="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
TIMEOUT=30

jq '.profile.exit_type = "Normal"' "$PREF" | sponge "$PREF"

brave --restore-last-session &
BRAVE_PID=$!

# Monitor for up to TIMEOUT seconds
elapsed=0
while [ $elapsed -lt $TIMEOUT ]; do
    if ! kill -0 $BRAVE_PID 2>/dev/null; then
        echo "Brave stopped running – relaunching normally."
        brave &
        exit 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
done

echo "Brave stable for $TIMEOUT seconds."
exit 0
