vim.schedule(function()
  require('telescope').setup {
    defaults = {
      -- NvChad's telescope proportions and prompt glyphs.
      prompt_prefix = '   ',
      selection_caret = '  ',
      entry_prefix = '   ',
      sorting_strategy = 'ascending',
      layout_strategy = 'horizontal',
      borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
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

-- NvChad's bordered telescope look, mapped onto carbonfox.
--
-- The trick is that each pane's border fg equals its own bg, so the borders
-- vanish and the prompt, results and preview read as three detached blocks
-- rather than one framed window. The prompt sits on a lighter background than
-- the results so the split is visible without a drawn line.
local theme = {
  bg = '#0c0c0c', -- results + preview: a step darker than Normal (#161616)
  prompt_bg = '#202020', -- prompt: a step lighter, so it separates
  fg = '#f2f4f8',
  black = '#161616',
  red = '#ee5396',
  green = '#25be6a',
  selection = '#2a2a2a',
}

local function apply_telescope_theme()
  local set = vim.api.nvim_set_hl
  -- Results and preview: dark, borderless.
  set(0, 'TelescopeNormal', { fg = theme.fg, bg = theme.bg })
  set(0, 'TelescopeBorder', { fg = theme.bg, bg = theme.bg })
  set(0, 'TelescopeResultsNormal', { fg = theme.fg, bg = theme.bg })
  set(0, 'TelescopeResultsBorder', { fg = theme.bg, bg = theme.bg })
  set(0, 'TelescopeResultsTitle', { fg = theme.bg, bg = theme.bg })
  set(0, 'TelescopePreviewNormal', { fg = theme.fg, bg = theme.bg })
  set(0, 'TelescopePreviewBorder', { fg = theme.bg, bg = theme.bg })
  set(0, 'TelescopePreviewTitle', { fg = theme.black, bg = theme.green, bold = true })
  -- Prompt: lighter block, with a coloured title tab.
  set(0, 'TelescopePromptNormal', { fg = theme.fg, bg = theme.prompt_bg })
  set(0, 'TelescopePromptBorder', { fg = theme.prompt_bg, bg = theme.prompt_bg })
  set(0, 'TelescopePromptTitle', { fg = theme.black, bg = theme.red, bold = true })
  set(0, 'TelescopePromptPrefix', { fg = theme.red, bg = theme.prompt_bg })
  set(0, 'TelescopeSelection', { fg = theme.fg, bg = theme.selection })
  set(0, 'TelescopeMatching', { fg = theme.red, bold = true })
end

apply_telescope_theme()

-- A :colorscheme re-apply resets every highlight group, so re-assert these.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('telescope-theme', { clear = true }),
  callback = apply_telescope_theme,
})

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
