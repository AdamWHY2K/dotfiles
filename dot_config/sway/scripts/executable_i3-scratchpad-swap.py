#!/usr/bin/env python3

import sys
from i3ipc import Connection

SCRATCH_WS_NAMES = ('__i3_scratchpad', '__i3_scratch')

def main():
    # i3ipc connects to $SWAYSOCK if the script runs under Sway
    sway = Connection()
    tree = sway.get_tree()
    focused = tree.find_focused()
    focused_id = focused.id if focused else None

    # Gather all scratchpad nodes, hidden and open
    all_sp_nodes = []
    for node in tree.descendants():
        state = getattr(node, 'scratchpad_state', 'none')
        if state not in ('none', None):
            parent_state = getattr(node.parent, 'scratchpad_state', 'none') if node.parent else 'none'
            if parent_state not in ('none', None):
                continue
            all_sp_nodes.append(node)

    if not all_sp_nodes:
        sys.exit(0)

    all_sp_nodes.sort(key=lambda x: x.id)

    # Find the scratchpad node that is open now, focused or not
    visible_node = None
    visible_ws_name = None
    for node in all_sp_nodes:
        ws = node.workspace()
        if ws and ws.name not in SCRATCH_WS_NAMES:
            visible_node = node
            visible_ws_name = ws.name
            break

    if visible_node is None:
        sys.exit(0)

    if len(all_sp_nodes) == 1:
        sys.exit(0)

    current_idx = [n.id for n in all_sp_nodes].index(visible_node.id)

    move_left = (len(sys.argv) > 1) and (sys.argv[1] == 'left')
    step = -1 if move_left else 1
    next_idx = (current_idx + step) % len(all_sp_nodes)
    next_node = all_sp_nodes[next_idx]
    
    # Focus the scratchpad first so we don't break fullscreen mode
    sway.command(f'[con_id={visible_node.id}] focus')

    # Hide the window that is open now
    sway.command(f'[con_id={visible_node.id}] move scratchpad')

    # Show the next window on the same workspace the old one was on
    sway.command(f'[con_id={next_node.id}] move workspace {visible_ws_name}, move position center')

    if focused_id == visible_node.id:
        # The scratchpad had focus, so the new scratchpad window should too
        sway.command(f'[con_id={next_node.id}] focus')
    else:
        # Restore original window focus
        sway.command(f'[con_id={focused_id}] focus')

if __name__ == '__main__':
    main()
