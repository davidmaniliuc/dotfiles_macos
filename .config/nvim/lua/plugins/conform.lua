require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- C and C++ have no standard style worth enforcing on every save.
    local no_lsp_fallback = { c = true, cpp = true }
    return {
      timeout_ms = 500,
      lsp_format = no_lsp_fallback[vim.bo[bufnr].filetype] and 'never' or 'fallback',
    }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_fix', 'ruff_organize_imports', 'ruff_format' },
    go = { 'gofmt' },
    rust = { 'rustfmt' },
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    css = { 'prettier' },
    html = { 'prettier' },
    json = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
  },
}

-- <leader>f is the telescope prefix, so format lives on <leader>F. Binding it to
-- <leader>f would make every format wait out timeoutlen.
vim.keymap.set({ 'n', 'v' }, '<leader>F', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = 'Format buffer' })
