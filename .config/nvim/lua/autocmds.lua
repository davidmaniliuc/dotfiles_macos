local augroup = vim.api.nvim_create_augroup

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Briefly highlight yanked text',
  group = augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Claude Code rewrites files on disk under open buffers. Reload aggressively,
-- and never silently: `confirm` handles the unsaved-edits-plus-disk-change case.
local external = augroup('external-change', { clear = true })

vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI', 'FocusGained', 'TermLeave' }, {
  desc = 'Check for changes made outside Neovim',
  group = external,
  pattern = '*',
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.bo.buftype == '' then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd('FileChangedShellPost', {
  desc = 'Announce buffers reloaded from disk',
  group = external,
  callback = function()
    vim.notify('Reloaded from disk: ' .. vim.fn.expand '<afile>', vim.log.levels.WARN)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'C uses block comments',
  group = augroup('ft-tweaks', { clear = true }),
  pattern = 'c',
  callback = function()
    vim.bo.commentstring = '/* %s */'
  end,
})
