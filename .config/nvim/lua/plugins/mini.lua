-- Four modules, one repository. mini.statusline is deliberately absent:
-- the statusline is Neovim's stock one.
--
-- Ruling S2-T11a step 2: requiring and setting up the mini.nvim submodules
-- at startup measured ~6-10ms. None of it is needed before the first draw
-- after startup -- same reasoning as options.lua's clipboard deferral --
-- so defer the whole block by one event-loop tick with vim.schedule. This
-- callback is NOT guaranteed to have run yet by the time scripts/check.lua
-- (or any other -c command) starts executing -- vim.schedule only queues it,
-- and no -c argument chain drains that queue on its own. scripts/check.lua:55
-- drains it explicitly with vim.wait(0) before asserting anything that
-- depends on this block having run; see that comment for the full story.
vim.schedule(function()
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()

  require('mini.surround').setup()
  require('mini.ai').setup { n_lines = 500 }
  require('mini.pairs').setup()
end)
