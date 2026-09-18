local map = vim.keymap.set

-- Buffers
map('n', '<leader>bk', '<cmd>bd<CR>', { desc = 'Kill buffer' })
map('n', '<leader>bd', '<cmd>%bd|e#|bd#<CR><CR>', { desc = 'Kill other buffers' })
map('n', 'H', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
map('n', 'L', '<cmd>bnext<CR>', { desc = 'Next buffer' })

-- Misc
map('n', '<leader>dm', '<cmd>delmarks!<CR>', { desc = 'Delete marks' })
map('n', '<leader>cd', '<cmd>cd %:p:h<CR>', { desc = 'cd to file directory' })
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Marks: ' jumps to the exact position, ` to the line
map('n', "'", '`', { desc = 'Jump to exact mark position' })
map('n', '`', "'", { desc = 'Jump to mark line' })

-- Window navigation. The old config had a typo here: <Cmw><C-k>.
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
