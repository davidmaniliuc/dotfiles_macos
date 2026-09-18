-- Merged over nvim-lspconfig's lsp/lua_ls.lua by vim.lsp.enable.
return {
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}
