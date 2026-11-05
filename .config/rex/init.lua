-- Rex keybindings, carried over from .config/ghostty/config.
--
-- cmd+g is the prefix, as in Ghostty: press cmd+g, then the key.

-- Splits. shift flips the direction: s/S is right/left, d/D is down/up.
rex.bind('cmd+g>s', 'pane.split.right')
rex.bind('cmd+g>shift+s', 'pane.split.left')
rex.bind('cmd+g>d', 'pane.split.down')
rex.bind('cmd+g>shift+d', 'pane.split.up')

-- Move between panes with hjkl.
rex.bind('cmd+g>h', 'pane.focus.left')
rex.bind('cmd+g>j', 'pane.focus.down')
rex.bind('cmd+g>k', 'pane.focus.up')
rex.bind('cmd+g>l', 'pane.focus.right')

rex.bind('cmd+g>c', 'client.tab.new')
rex.bind('cmd+g>z', 'pane.zoom')
rex.bind('cmd+g>x', 'pane.close')
