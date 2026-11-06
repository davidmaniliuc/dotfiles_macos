-- term16_dark uses the terminal's 16 ANSI colors, which termguicolors would ignore.
vim.o.termguicolors = false
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

-- Helix-style mode label (NOR/INS/VIS/V-L/V-B) in front of Neovim's stock statusline.
local mode_labels = {
  n = 'NOR', i = 'INS', R = 'REP', c = 'CMD', t = 'TRM',
  v = 'VIS', V = 'V-L', ['\22'] = 'V-B', s = 'SEL', S = 'S-L', ['\19'] = 'S-B',
}
function _G.statusline_mode()
  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  return mode_labels[mode] or mode
end
vim.o.statusline = ' %{v:lua.statusline_mode()}   ' .. vim.api.nvim_get_option_info2('statusline', {}).default
-- The statusline isn't redrawn on every mode switch by itself.
vim.api.nvim_create_autocmd('ModeChanged', { command = 'redrawstatus' })

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
vim.o.sidescrolloff = 5
vim.o.confirm = true
vim.o.autoread = true

-- Native folding powered by Tree-sitter. Start buffers expanded while keeping
-- all of Neovim's standard z folding commands available.
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99
vim.o.foldenable = true

-- 0.12: one global border for every float. Replaces wrapping vim.lsp.buf.hover.
vim.o.winborder = 'single'

-- The entire completion configuration. See lua/lsp.lua for the enable call.
vim.o.completeopt = 'menu,menuone,noselect,popup,fuzzy'
