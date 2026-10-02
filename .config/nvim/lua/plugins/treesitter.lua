local ts = require 'nvim-treesitter'

local ensure = {
  'bash',
  'c',
  'diff',
  'git_config',
  'git_rebase',
  'gitcommit',
  'go',
  'gomod',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'odin',
  'python',
  'query',
  'regex',
  'rust',
  'toml',
  'tsx',
  'typescript',
  'typst',
  'vim',
  'vimdoc',
  'yaml',
  'zig',
}

local installed = {}
for _, p in ipairs(require('nvim-treesitter.config').get_installed 'parsers') do
  installed[p] = true
end

local missing = vim.tbl_filter(function(p)
  return not installed[p]
end, ensure)

if #missing > 0 then
  ts.install(missing)
end

-- Metal Shading Language is C++14-based and has no grammar of its own in
-- nvim-treesitter, and stock Neovim does not detect `.metal` at all.
vim.filetype.add { extension = { metal = 'metal' } }
vim.treesitter.language.register('cpp', 'metal')

-- Returns true if highlighting started. Filetypes with no installed (or no
-- existing) parser are the normal case -- most buffers opened day to day --
-- so a failed start must be silently skipped rather than erroring on every
-- buffer. It is vim.treesitter.start (via get_parser) that raises for a
-- parserless filetype, e.g. "TelescopePrompt" -- language.add does not:
-- get_lang falls back to returning the filetype itself as the language, and
-- language.add "succeeds" by returning nil/false rather than erroring, so
-- guarding it (as this used to) does not catch the failure.
local function attach(buf, lang)
  if not pcall(vim.treesitter.start, buf, lang) then
    return false
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  return true
end

-- Languages nvim-treesitter can install, built on first use: get_available
-- fires the TSUpdate autocmd and walks the whole registry. The 'unsupported'
-- tier is excluded -- install() silently skips those anyway.
local installable
local function can_install(lang)
  if not installable then
    installable = {}
    local tiers = require('nvim-treesitter.config').tiers
    for tier = 1, #tiers do
      if tiers[tier] ~= 'unsupported' then
        for _, p in ipairs(ts.get_available(tier)) do
          installable[p] = true
        end
      end
    end
  end
  return installable[lang] == true
end

-- Languages whose install is in flight, so reopening a buffer mid-install
-- does not queue a second one.
local installing = {}

-- Installs `lang` in the background, then attaches every loaded buffer that
-- wants it, not only the one that triggered the install.
local function install_then_attach(lang)
  installing[lang] = true
  vim.notify('treesitter: installing ' .. lang .. ' parser…')
  ts.install(lang):await(function(err)
    vim.schedule(function()
      installing[lang] = nil
      if err then
        vim.notify('treesitter: ' .. lang .. ' install failed: ' .. tostring(err), vim.log.levels.ERROR)
        return
      end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.treesitter.language.get_lang(vim.bo[buf].filetype) == lang then
          attach(buf, lang)
        end
      end
    end)
  end)
end

-- main-branch nvim-treesitter does not register highlighting itself, nor
-- install parsers on demand: `ensure` above is the baseline, and any other
-- language nvim-treesitter knows is installed the first time it is opened.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter', { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if not lang or attach(ev.buf, lang) then
      return
    end
    if not installing[lang] and can_install(lang) then
      install_then_attach(lang)
    end
  end,
})

return { ensure = ensure }
