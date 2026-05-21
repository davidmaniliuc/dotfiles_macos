vim.opt.termguicolors = true
vim.opt.pumheight = 10
vim.opt.cmdheight = 0
vim.opt.conceallevel = 0
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.fillchars:append { eob = ' ' }

-- Make line numbers default
vim.opt.number = true
vim.wo.relativenumber = true
vim.opt.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} '

vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- two spaces tab
vim.opt.tabstop = 2 -- Defines how many spaces a tab character represents
vim.opt.shiftwidth = 2 -- Determines indentation size for automatic indentation
vim.opt.expandtab = true -- Converts tabs to spaces
vim.opt.softtabstop = 2 -- Controls the number of spaces for editing operations

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.opt.confirm = true

local _hover = vim.lsp.buf.hover

vim.lsp.buf.hover = function(opts)
  opts = opts or {}
  opts.border = opts.border or 'single'
  return _hover(opts)
end

vim.api.nvim_create_augroup('CCommentStyle', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'CCommentStyle',
  pattern = 'c',
  command = 'setlocal commentstring=/*\\ %s\\ */',
})

vim.opt.autoread = true

-- Create an autocmd to check for changes more aggressively
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI', 'FocusGained' }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = '*',
})

-- vim: ts=2 sts=2 sw=2 et
