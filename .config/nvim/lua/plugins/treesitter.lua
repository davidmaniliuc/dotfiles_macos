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

-- main-branch nvim-treesitter does not register highlighting itself.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter', { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if not lang then
      return
    end
    -- Filetypes with no installed (or no existing) parser are the normal
    -- case -- most buffers opened day to day -- so a failed start must be
    -- silently skipped rather than erroring on every buffer. It is
    -- vim.treesitter.start (via get_parser) that raises for a parserless
    -- filetype, e.g. "TelescopePrompt" -- language.add does not: get_lang
    -- falls back to returning the filetype itself as the language, and
    -- language.add "succeeds" by returning nil/false rather than erroring,
    -- so guarding it (as this used to) does not catch the failure.
    if not pcall(vim.treesitter.start, ev.buf, lang) then
      return
    end
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

return { ensure = ensure }
