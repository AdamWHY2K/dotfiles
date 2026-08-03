#!/usr/bin/env python3

import sys
from i3ipc import Connection

def main():
    # i3ipc automatically connects to $SWAYSOCK if running under Sway
    sway = Connection()
    tree = sway.get_tree()
    focused = tree.find_focused()
    
    if not focused:
        sys.exit(0)

    # 1. Verify if the currently focused window is a scratchpad window
    cur_con_is_sp = False
    p = focused
    sp_container = None
    
    while p and p.type != 'workspace':
        # Safely handle states that might be returned as None or 'none'
        state = getattr(p, 'scratchpad_state', 'none')
        if state not in ('none', None):
            cur_con_is_sp = True
            sp_container = p
            break
        p = p.parent

    if not cur_con_is_sp:
        print('I am not a scratchpad')
        sys.exit(0)

    # 2. Gather all scratchpad nodes (both hidden and currently visible)
    all_sp_nodes = []
    for node in tree.descendants():
        state = getattr(node, 'scratchpad_state', 'none')
        if state not in ('none', None):
            # Only grab the top-level scratchpad container to avoid duplicates 
            parent_state = getattr(node.parent, 'scratchpad_state', 'none') if node.parent else 'none'
            if parent_state not in ('none', None):
                continue
            all_sp_nodes.append(node)

    # Sort them by ID so the cycle order is predictable and consistent
    all_sp_nodes.sort(key=lambda x: x.id)

    if not all_sp_nodes:
        sys.exit(0)

    # 3. Find the array index of the currently focused scratchpad container
    try:
        current_idx = [n.id for n in all_sp_nodes].index(sp_container.id)
    except ValueError:
        sys.exit(0)

    # 4. Calculate the next index based on direction
    move_left = (len(sys.argv) > 1) and (sys.argv[1] == 'left')
    step = -1 if move_left else 1
    next_idx = (current_idx + step) % len(all_sp_nodes)

    # 5. Execute commands
    # If it's the only scratchpad window in existence, just hide it
    if current_idx == next_idx:
        sway.command('scratchpad show')
        sys.exit(0)

    next_node = all_sp_nodes[next_idx]

    # Hide the currently focused scratchpad window
    sway.command(f'[con_id={sp_container.id}] scratchpad show')
    
    # Reveal and focus the next scratchpad window in the cycle
    sway.command(f'[con_id={next_node.id}] scratchpad show')
    sway.command(f'[con_id={next_node.id}] focus')

if __name__ == '__main__':
    main()
