# nvim

A lean Neovim 0.12 configuration: 13 plugins, native LSP, native completion,
`vim.pack` for package management, and no editor-scoped binary installer.

Claude Code is the primary editor here. Neovim reads code, navigates it, reviews
the diffs the agent produces, and makes small targeted edits.

## Install

```bash
git clone <this repo> ~/.config/nvim
~/.config/nvim/scripts/install-tools.sh
nvim
```

Plugins install themselves on first launch from `nvim-pack-lock.json`.

## Layout

| path | responsibility |
|---|---|
| `lua/options.lua` | options only |
| `lua/keymaps.lua` | global keymaps |
| `lua/autocmds.lua` | yank highlight, external-change reload, filetype tweaks |
| `lua/pack.lua` | the only caller of `vim.pack.add` |
| `lua/lsp.lua` | diagnostics, server list, `LspAttach` |
| `lua/plugins/*.lua` | configuration only, never installs |
| `lsp/*.lua` | per-server overrides, found on the runtimepath |
| `scripts/install-tools.sh` | installs servers and formatters from system toolchains |
| `scripts/check.lua` | verification suite |

## Keymaps

Leader is `<Space>`.

### Find
`<leader><leader>` files · `<leader>fg` grep · `<leader>fw` word under cursor ·
`<leader>fb` buffers · `<leader>fc` changed files · `<leader>fd` diagnostics ·
`<leader>fh` help · `<leader>fk` keymaps · `<leader>fs` telescope builtins ·
`<leader>fr` resume · `<leader>/` in buffer

### Review
`<leader>gd` working tree diff · `<leader>gD` last commit · `<leader>gh` file history ·
`<leader>gq` close · `<leader>gb` blame · `<leader>gs` stage hunk ·
`<leader>gr` reset hunk · `<leader>gp` preview hunk · `]c` / `[c` hunk navigation

### LSP
`gd` definition · `gD` declaration · `K` hover (set by Neovim core on attach, not by this config) ·
`grn` rename · `gra` code action · `grr` references · `gri` implementation ·
`grt` type definition · `grx` run codelens · `gO` symbols ·
`<C-s>` signature help (insert mode) · `<leader>th` toggle inlay hints ·
`<leader>q` diagnostics to loclist

### Other
`-` oil · `<leader>F` format · `H` / `L` buffers · `<leader>bk` kill buffer ·
`<leader>bd` kill others · `s` surround prefix (`sa` add, `sd` delete, `sr` replace)

## Maintaining

```vim
:lua vim.pack.update()
```

Review the confirmation buffer, `:write` to accept or `:quit` to discard, then
`:restart`. Commit the updated `nvim-pack-lock.json`.

Add a plugin: one entry in `lua/pack.lua`, one file in `lua/plugins/`.
Add a language server: install the binary in `scripts/install-tools.sh`, add its
name to the list in `lua/lsp.lua`. Only add an `lsp/<name>.lua` file if it needs
settings beyond nvim-lspconfig's defaults.

## Verifying

```bash
NVIM_APPNAME=nvim-next nvim --headless -c "luafile $PWD/scripts/check.lua" -c 'qa!'
```

## Deliberately absent

No mason (system toolchains instead, so Claude Code sees the same binaries).
No completion plugin (`vim.lsp.completion`). No DAP (debug in the terminal).
No Claude Code integration plugin. No leap.nvim: its GitHub repository was
emptied upstream (2026-09-07, the author moved to Codeberg), so the motion
layer was dropped by choice rather than repointed at a new source. No autosave
— a background write is how you lose work an agent just produced.
