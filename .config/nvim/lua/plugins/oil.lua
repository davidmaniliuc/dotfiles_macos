require('oil').setup {
  default_file_explorer = true,
  view_options = { show_hidden = true },
  -- Renaming a file that an agent is mid-edit on is not worth the surprise.
  prompt_save_on_select_new_entry = true,
  keymaps = {
    ['<Esc>'] = 'actions.close',
  },
}

vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })
