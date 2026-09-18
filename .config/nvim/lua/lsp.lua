vim.diagnostic.config {
  severity_sort = true,
  underline = { severity = vim.diagnostic.severity.ERROR },
  -- Only errors get inline text; warnings would drown the buffer while reading.
  virtual_text = { severity = { min = vim.diagnostic.severity.ERROR }, source = 'if_many' },
  float = { source = 'if_many' },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or true,
}

vim.lsp.enable {
  'lua_ls',
  'bashls',
  'gopls',
  'ruff',
  'ty',
  'rust_analyzer',
  'ts_ls',
  'zls',
  'tinymist',
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    local map = function(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end

    -- 0.12+ already binds grn, gra, grr, gri, grt, grx, gO, K, and <C-s>
    -- (signature help, insert mode). Only add the gaps.
    --
    -- Deliberately eager, unlike lua/plugins/telescope.lua's identical
    -- require, which defers into each keymap's own callback specifically to
    -- avoid pulling in telescope's runtime before a picker is opened. This
    -- call site cannot do that: it runs inside LspAttach, once per buffer,
    -- so a deferred `function() require(...).lsp_definitions(...) end` would
    -- allocate a fresh closure on every attach, and scripts/check.lua's "gd
    -- ... are bound in an LSP buffer" check asserts callback identity against
    -- the stable `lsp_definitions` function value -- which only exists if
    -- this require runs once, here, eagerly.
    map('gd', require('telescope.builtin').lsp_definitions, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')

    -- The entire completion stack.
    if client:supports_method 'textDocument/completion' then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    if client:supports_method 'textDocument/inlayHint' then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf }, { bufnr = ev.buf })
      end, 'Toggle inlay hints')
    end
  end,
})
