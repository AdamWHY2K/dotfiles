#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/sway/config"

# Default state
CRITERION="app_id"
FLOAT="false"
STICKY="false"
SCRATCH="false"
FULLSCREEN="false"
OPACITY=""
WORKSPACE=""
OUTPUT=""
BORDER=""
MARK=""
LAYOUT=""
IDLE_INHIBIT=""

# ----------------------------------------------------------------------
# Helper: print the interactive menu
# ----------------------------------------------------------------------
print_menu() {
    clear
    echo "═══════════════════════════════════════════════════════════════════"
    echo "  SWAY WINDOW RULE BUILDER  (Click target window after confirm)   "
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    printf "  [TARGET] %-8s (press 't' to cycle)\n" "$CRITERION"
    echo ""
    echo "  ─── Toggleable Options ───"
    # Floating
    printf "  [%s] (f) Floating" "$( [[ "$FLOAT" == "true" ]] && echo "X" || echo " " )"
    printf "       [%s] (s) Sticky" "$( [[ "$STICKY" == "true" ]] && echo "X" || echo " " )"
    printf "        [%s] (p) Scratchpad\n" "$( [[ "$SCRATCH" == "true" ]] && echo "X" || echo " " )"
    
    printf "  [%s] (u) Fullscreen" "$( [[ "$FULLSCREEN" == "true" ]] && echo "X" || echo " " )"
    printf "       [%s] (a) Opacity: %s" "$( [[ -n "$OPACITY" ]] && echo "X" || echo " " )" "${OPACITY:-not set}"
    printf "   [%s] (l) Layout: %s\n" "$( [[ -n "$LAYOUT" ]] && echo "X" || echo " " )" "${LAYOUT:-not set}"
    echo ""
    echo "  ─── Value Prompts (press key to set) ───"
    printf "  (w) Workspace : %s\n" "${WORKSPACE:-not set}"
    printf "  (o) Output    : %s\n" "${OUTPUT:-not set}"
    printf "  (b) Border    : %s\n" "${BORDER:-not set}"
    printf "  (m) Mark      : %s\n" "${MARK:-not set}"
    printf "  (i) Idle Inhibit : %s\n" "${IDLE_INHIBIT:-not set}"
    echo ""
    echo "  ─── Preview ─────────────────────────────────────────────────────"
    echo "  $(build_rule_preview)"
    echo "  ─────────────────────────────────────────────────────────────────"
    echo ""
    echo "  Press (c) to CONFIRM & fetch window  |  (q) to Quit"
}

# ----------------------------------------------------------------------
# Build the command string (without the for_window prefix)
# ----------------------------------------------------------------------
build_commands() {
    local cmds=()
    [[ "$FLOAT" == "true" ]] && cmds+=("floating enable")
    [[ "$STICKY" == "true" ]] && cmds+=("sticky enable")
    [[ "$SCRATCH" == "true" ]] && cmds+=("move to scratchpad")
    [[ "$FULLSCREEN" == "true" ]] && cmds+=("fullscreen enable")
    [[ -n "$OPACITY" ]] && cmds+=("opacity $OPACITY")
    [[ -n "$WORKSPACE" ]] && cmds+=("move to workspace $WORKSPACE")
    [[ -n "$OUTPUT" ]] && cmds+=("move to output $OUTPUT")
    [[ -n "$BORDER" ]] && cmds+=("border $BORDER")
    [[ -n "$MARK" ]] && cmds+=("mark --add \"$MARK\"")
    [[ -n "$LAYOUT" ]] && cmds+=("layout $LAYOUT")
    [[ -n "$IDLE_INHIBIT" ]] && cmds+=("inhibit_idle $IDLE_INHIBIT")
    
    # Join with commas
    local IFS=,
    echo "${cmds[*]}"
}

build_rule_preview() {
    local cmd_str=$(build_commands)
    if [[ -z "$cmd_str" ]]; then
        echo "  (No rules selected yet)"
    else
        echo "  for_window [${CRITERION}=\"...\"] $cmd_str"
    fi
}

# ----------------------------------------------------------------------
# Parse command-line arguments (non-interactive mode)
# ----------------------------------------------------------------------
INTERACTIVE=false
while getopts "w:b:fsmtcI h" opt; do
    case $opt in
        w) WORKSPACE="$OPTARG" ;;
        b) BORDER="$OPTARG" ;;
        f) FLOAT="true" ;;
        s) STICKY="true" ;;
        m) SCRATCH="true" ;;
        t) CRITERION="name" ;;
        c) CRITERION="class" ;;
        I) INTERACTIVE=true ;;
        h) 
            echo "Usage: $0 [OPTIONS]"
            echo "Click a window after running the script."
            echo ""
            echo "Options:"
            echo "  -w <ws>    Move to workspace (e.g., -w 3, -w \"5:Terminals\")"
            echo "  -f         Enable floating"
            echo "  -s         Enable sticky"
            echo "  -m         Move to scratchpad"
            echo "  -b <style> Set border (e.g., -b \"pixel 2\", -b normal)"
            echo "  -t         Use window title (name) instead of app_id"
            echo "  -c         Use XWayland class instead of app_id"
            echo "  -I         Force interactive mode (even with flags)"
            echo "  -h         Show this help"
            exit 0
            ;;
        *) 
            echo "Invalid option. Use -h for help."
            exit 1
            ;;
    esac
done

# If no flags are given, or -I is set, go interactive
if [ $# -eq 0 ] || [ "$INTERACTIVE" == "true" ]; then
    INTERACTIVE=true
fi

# ----------------------------------------------------------------------
# Interactive loop
# ----------------------------------------------------------------------
if [ "$INTERACTIVE" == "true" ]; then
    while true; do
        print_menu
        read -s -n1 key
        case "$key" in
            t) # Cycle target criterion: app_id -> name -> class -> instance -> app_id
                if [[ "$CRITERION" == "app_id" ]]; then
                    CRITERION="name"
                elif [[ "$CRITERION" == "name" ]]; then
                    CRITERION="class"
                elif [[ "$CRITERION" == "class" ]]; then
                    CRITERION="instance"
                else
                    CRITERION="app_id"
                fi
                ;;
            f) # Toggle floating
                if [[ "$FLOAT" == "true" ]]; then FLOAT="false"; else FLOAT="true"; fi
                ;;
            s) # Toggle sticky
                if [[ "$STICKY" == "true" ]]; then STICKY="false"; else STICKY="true"; fi
                ;;
            p) # Toggle scratchpad
                if [[ "$SCRATCH" == "true" ]]; then SCRATCH="false"; else SCRATCH="true"; fi
                ;;
            u) # Toggle fullscreen
                if [[ "$FULLSCREEN" == "true" ]]; then FULLSCREEN="false"; else FULLSCREEN="true"; fi
                ;;
            a) # Set opacity
                echo -e "\nEnter opacity (0.1 to 1.0): "
                read -r val
                [[ -n "$val" ]] && OPACITY="$val" || OPACITY=""
                ;;
            l) # Set layout
                echo -e "\nEnter layout (tabbed/stacking/split): "
                read -r val
                [[ -n "$val" ]] && LAYOUT="$val" || LAYOUT=""
                ;;
            w) # Set workspace
                echo -e "\nEnter workspace (e.g., 3 or '3:Web'): "
                read -r val
                [[ -n "$val" ]] && WORKSPACE="$val" || WORKSPACE=""
                ;;
            o) # Set output
                echo -e "\nEnter output name (e.g., HDMI-A-1): "
                read -r val
                [[ -n "$val" ]] && OUTPUT="$val" || OUTPUT=""
                ;;
            b) # Set border
                echo -e "\nEnter border (none/normal/pixel X): "
                read -r val
                [[ -n "$val" ]] && BORDER="$val" || BORDER=""
                ;;
            m) # Set mark
                echo -e "\nEnter mark name (e.g., 'main'): "
                read -r val
                [[ -n "$val" ]] && MARK="$val" || MARK=""
                ;;
            i) # Set idle inhibit
                echo -e "\nEnter idle inhibit (open/fullscreen/visible): "
                read -r val
                [[ -n "$val" ]] && IDLE_INHIBIT="$val" || IDLE_INHIBIT=""
                ;;
            c) # Confirm
                echo -e "\n✅ Confirmed! Now click on the target window..."
                break
                ;;
            q) # Quit
                echo -e "\nExited."
                exit 0
                ;;
        esac
    done
fi

# ----------------------------------------------------------------------
# Fetch the window property using wlprop (with correct JSON paths)
# ----------------------------------------------------------------------
echo "Click on the target window..."
PROP_JSON=$(wlprop)

case "$CRITERION" in
    app_id)
        JSON_PATH=".app_id"
        ;;
    name)
        JSON_PATH=".name"
        ;;
    class)
        JSON_PATH=".window_properties.class"
        ;;
    instance)
        JSON_PATH=".window_properties.instance"
        ;;
    *)
        JSON_PATH=".${CRITERION}"
        ;;
esac

VALUE=$(echo "$PROP_JSON" | jq -r "$JSON_PATH")

# Friendly error messages for XWayland vs Wayland mismatches
if [ "$VALUE" = "null" ] && [[ "$JSON_PATH" == .window_properties.* ]]; then
    echo "ERROR: This window is a native Wayland window and does not have an XWayland '$CRITERION'."
    echo "Try switching the target to 'app_id' (press 't' in interactive mode)."
    echo "Available props:"
    echo "$PROP_JSON" | jq '.'
    exit 1
fi

if [ -z "$VALUE" ] || [ "$VALUE" = "null" ]; then
    echo "ERROR: Could not find property '$CRITERION' for that window."
    echo "Available props:"
    echo "$PROP_JSON" | jq '.'
    exit 1
fi

# ----------------------------------------------------------------------
# Build final rule and append to config
# ----------------------------------------------------------------------
CMD_STRING=$(build_commands)
if [ -z "$CMD_STRING" ]; then
    echo "No commands selected. Nothing to add."
    exit 0
fi

NEW_RULE="for_window [${CRITERION}=\"$VALUE\"] $CMD_STRING"

echo "$NEW_RULE" >> "$CONFIG_FILE"
echo ""
echo "✅ Added to $CONFIG_FILE:"
echo "   $NEW_RULE"

# Reload Sway to apply immediately
swaymsg reload
echo "✅ Sway reloaded. Test it by reopening the application."
