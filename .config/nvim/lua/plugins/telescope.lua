vim.schedule(function()
  require('telescope').setup {
    defaults = {
      -- NvChad's telescope proportions and prompt glyphs.
      prompt_prefix = '   ',
      selection_caret = '  ',
      entry_prefix = '   ',
      sorting_strategy = 'ascending',
      layout_strategy = 'horizontal',
      layout_config = {
        prompt_position = 'top',
        preview_cutoff = 120,
        horizontal = { preview_width = 0.55, results_width = 0.8 },
        vertical = { mirror = false },
        width = 0.87,
        height = 0.80,
      },
    },
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  require('telescope').load_extension 'fzf'
  require('telescope').load_extension 'ui-select'
end)

-- Ruling S2-T11a: `require('telescope.builtin')` at the top level eagerly pulls
-- `telescope.pickers` and most of telescope's runtime just to bind keymaps --
-- nothing needs any of that until the first picker actually opens. Each
-- keymap below requires it lazily, inside its own callback, instead.
local map = vim.keymap.set

map('n', '<leader><leader>', function()
  require('telescope.builtin').find_files()
end, { desc = 'Find files' })
map('n', '<leader>fg', function()
  require('telescope.builtin').live_grep()
end, { desc = 'Grep' })
map('n', '<leader>fw', function()
  require('telescope.builtin').grep_string()
end, { desc = 'Grep word under cursor' })
map('n', '<leader>fh', function()
  require('telescope.builtin').help_tags()
end, { desc = 'Help tags' })
map('n', '<leader>fk', function()
  require('telescope.builtin').keymaps()
end, { desc = 'Keymaps' })
map('n', '<leader>fs', function()
  require('telescope.builtin').builtin()
end, { desc = 'Telescope builtins' })
map('n', '<leader>fb', function()
  require('telescope.builtin').buffers()
end, { desc = 'Buffers' })
map('n', '<leader>fd', function()
  require('telescope.builtin').diagnostics()
end, { desc = 'Diagnostics' })
map('n', '<leader>fr', function()
  require('telescope.builtin').resume()
end, { desc = 'Resume last picker' })

-- The files Claude Code just touched. Expect this to be the most-used key here.
map('n', '<leader>fc', function()
  require('telescope.builtin').git_status()
end, { desc = 'Changed files' })

map('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Fuzzy find in buffer' })
