local gs = require 'gitsigns'

-- Shared by the buffer-local maps in on_attach and the global fallbacks
-- below, so the guard is not duplicated a third and fourth time. In a
-- diff-mode window (vim.wo.diff) defer to Vim's builtin ]c/[c instead of
-- gitsigns' own hunk nav -- gitsigns' hunks are useless in windows it has
-- not attached to (diffview's base pane, plain `nvim -d`), and calling
-- gs.nav_hunk there was a silent no-op that shadowed the builtin key.
local function nav_hunk(dir, builtin_key)
  return function()
    if vim.wo.diff then
      vim.cmd.normal { builtin_key, bang = true }
    else
      gs.nav_hunk(dir)
    end
  end
end

gs.setup {
  signs = {
    add = { text = '┃' },
    change = { text = '┃' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' },
  },
  on_attach = function(bufnr)
    local map = function(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = 'Git: ' .. desc })
    end

    map(']c', nav_hunk('next', ']c'), 'Next hunk')
    map('[c', nav_hunk('prev', '[c'), 'Previous hunk')

    map('<leader>gs', gs.stage_hunk, 'Stage hunk')
    map('<leader>gr', gs.reset_hunk, 'Reset hunk')
    map('<leader>gp', gs.preview_hunk, 'Preview hunk')
    map('<leader>gb', function()
      gs.blame_line { full = true }
    end, 'Blame line')
  end,
}

-- The on_attach maps are buffer-local and only exist once gitsigns attaches.
-- Register global fallbacks so the check suite and non-git buffers see them.
--
-- Per controller ruling B9: the brief left <leader>gp (preview hunk) out of
-- this fallback set even though it gave all five of its siblings one -- the
-- one key the plan added on purpose (deviation D3) was the one key with no
-- fallback and no assertion. Fixed by including it below.
--
-- ]c and [c reuse nav_hunk above, so these fallbacks carry the same
-- vim.wo.diff guard as their buffer-local twins in on_attach.
vim.keymap.set('n', ']c', nav_hunk('next', ']c'), { desc = 'Git: next hunk' })
vim.keymap.set('n', '[c', nav_hunk('prev', '[c'), { desc = 'Git: previous hunk' })
vim.keymap.set('n', '<leader>gs', gs.stage_hunk, { desc = 'Git: stage hunk' })
vim.keymap.set('n', '<leader>gr', gs.reset_hunk, { desc = 'Git: reset hunk' })
vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { desc = 'Git: preview hunk' })
vim.keymap.set('n', '<leader>gb', function()
  gs.blame_line { full = true }
end, { desc = 'Git: blame line' })
