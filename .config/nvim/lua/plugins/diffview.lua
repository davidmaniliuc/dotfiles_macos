-- Ruling S2-T11a step 2: `require('diffview').setup{}` alone measured
-- ~6-8ms at startup (diffview.bootstrap and friends), for config that
-- nothing needs until the user actually opens a review. Diffview's own
-- plugin/diffview.lua already registers :DiffviewOpen etc. independently of
-- this require, so deferring it costs nothing functionally -- same
-- reasoning as the telescope and mini deferrals above. This callback is NOT
-- guaranteed to have run yet by the time scripts/check.lua starts executing;
-- see scripts/check.lua:55 for why and how the suite drains it explicitly.
vim.schedule(function()
  require('diffview').setup {
    enhanced_diff_hl = true,
    view = {
      merge_tool = { layout = 'diff3_mixed' },
    },
  }
end)

local map = vim.keymap.set

-- Review everything Claude Code changed but has not committed.
map('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = 'Git: review working tree' })

-- Review the last commit, for when the agent committed before you looked.
map('n', '<leader>gD', '<cmd>DiffviewOpen HEAD~1<CR>', { desc = 'Git: review last commit' })

map('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', { desc = 'Git: file history' })
map('n', '<leader>gq', '<cmd>DiffviewClose<CR>', { desc = 'Git: close review' })
