-- [[ Basic Keymaps ]]
-- Set <Leader>bk to kill the current buffer
vim.api.nvim_set_keymap('n', '<Leader>bk', ':bd<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>bd', ':%bd|e#|bd#<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>dm', ':delmarks!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>cd', ':cd %:p:h<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', 'H', ':bprev<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'L', ':bnext<CR>', { noremap = true, silent = true })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<Cmw><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.keymap.set('n', "'", '`', { desc = 'Jump to exact mark position' })
vim.keymap.set('n', '`', "'", { desc = 'Jump to start of mark line' })
