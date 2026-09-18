local function gh(repo)
  return 'https://github.com/' .. repo
end

-- Build hooks must be registered BEFORE the first vim.pack.add call, otherwise
-- an install triggered from the lockfile fires before the autocmd exists.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack-build', { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
      -- Some macOS Xcode Command Line Tools installs have a default SDK
      -- symlink (what `xcrun --show-sdk-path` resolves without an explicit
      -- -sdk flag) that is stale or malformed relative to the active
      -- toolchain's linker, which makes plain `make` fail with a tapi
      -- "malformed file" error. Pin SDKROOT to the SDK the installed
      -- toolchain actually reports for -sdk macosx so the build succeeds
      -- regardless of that symlink's state. No-op on non-macOS.
      local env
      if vim.fn.has 'mac' == 1 then
        local sdk = vim.trim(vim.fn.system { 'xcrun', '-sdk', 'macosx', '--show-sdk-path' })
        if vim.v.shell_error == 0 and sdk ~= '' then
          env = { SDKROOT = sdk }
        end
      end
      local result = vim.system({ 'make' }, { cwd = ev.data.path, env = env, text = true }):wait()
      if result.code ~= 0 then
        vim.notify(string.format('%s: build failed (exit %d): %s', name, result.code, result.stderr), vim.log.levels.ERROR)
      end
    end
  end,
})

vim.pack.add({
  -- Navigation
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-fzf-native.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',

  -- Language intelligence
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  gh 'neovim/nvim-lspconfig',
  gh 'folke/lazydev.nvim',
  gh 'stevearc/conform.nvim',

  -- Git review
  gh 'lewis6991/gitsigns.nvim',
  gh 'sindrets/diffview.nvim',

  -- Editing and UI
  gh 'stevearc/oil.nvim',
  { src = gh 'nvim-mini/mini.nvim', version = 'stable' },
  gh 'EdenEast/nightfox.nvim',
  gh 'akinsho/bufferline.nvim',
}, {
  -- Default is true, which blocks headless runs on a confirmation prompt.
  confirm = false,
})
