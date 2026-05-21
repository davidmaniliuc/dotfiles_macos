return {
  url = 'https://codeberg.org/andyg/leap.nvim',
  event = 'BufEnter',
  config = function()
    vim.keymap.set({ 'n', 'x', 'o' }, 'z', function()
      require('leap').leap { target_windows = { vim.api.nvim_get_current_win() } }
    end)
  end,
}
