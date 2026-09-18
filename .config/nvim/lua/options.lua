vim.o.termguicolors = true
vim.o.pumheight = 10
vim.o.cmdheight = 0
vim.o.conceallevel = 0
vim.o.laststatus = 3
vim.o.showtabline = 2
-- bufferline's hover effect needs mouse-move reporting.
vim.o.mousemoveevent = true
vim.opt.fillchars:append { eob = ' ' }

vim.o.number = true
vim.o.relativenumber = true
vim.o.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} '
vim.o.showmode = false

-- Deferred: reading the system clipboard provider costs ~20ms at startup.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.autoread = true

-- 0.12: one global border for every float. Replaces wrapping vim.lsp.buf.hover.
vim.o.winborder = 'single'

-- The entire completion configuration. See lua/lsp.lua for the enable call.
vim.o.completeopt = 'menu,menuone,noselect,popup,fuzzy'
