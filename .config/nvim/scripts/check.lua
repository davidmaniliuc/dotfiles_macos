-- Verification suite. Run with:
--   NVIM_APPNAME=nvim-next nvim --headless -c "luafile $PWD/scripts/check.lua" -c 'qa!'
local failed = 0

-- Deferred minor (Task 11 addendum section 4, must-fix): under --headless,
-- consecutive `print()` calls go through Neovim's message/echo machinery,
-- which does not reliably terminate each call with its own newline -- two
-- PASS/FAIL lines can land on the same line of output (observed repeatedly;
-- it once cost this project a round of confusion over whether the suite had
-- 27 or 28 checks). `io.write` goes straight to the process's real stdout,
-- bypassing that machinery, so every check gets its own line.
local function out(line)
  io.write(line .. '\n')
end

local function check(name, fn)
  local ok, err = pcall(fn)
  if ok then
    out('PASS  ' .. name)
  else
    failed = failed + 1
    out('FAIL  ' .. name .. ' -- ' .. tostring(err))
  end
end

local function eq(got, want, what)
  assert(got == want, string.format('%s: got %s, want %s', what, vim.inspect(got), vim.inspect(want)))
end

-- nvim_get_keymap reports lhs in <> notation; normalise both sides so checks
-- can be written the way the config writes them.
local function norm(lhs)
  return vim.api.nvim_replace_termcodes(lhs, true, true, true)
end

local function find_map(mode, lhs, bufnr)
  local maps = bufnr and vim.api.nvim_buf_get_keymap(bufnr, mode) or vim.api.nvim_get_keymap(mode)
  for _, m in ipairs(maps) do
    if norm(m.lhs) == norm(lhs) then
      return m
    end
  end
end

local function assert_maps(mode, lhss, bufnr)
  local missing = {}
  for _, lhs in ipairs(lhss) do
    if not find_map(mode, lhs, bufnr) then
      table.insert(missing, lhs)
    end
  end
  assert(#missing == 0, 'missing keymaps: ' .. table.concat(missing, ', '))
end

-- Ordering fragility, same class as Ruling S2-T11b below (recorded here
-- instead of there because this one is a startup-vs-script-timing issue,
-- not a check-vs-check one): lua/plugins/telescope.lua, lua/plugins/mini.lua
-- and lua/plugins/diffview.lua defer their `setup{}` calls with
-- `vim.schedule()` for the Task 11 startup budget. Those callbacks have NOT
-- necessarily run yet when this script starts -- `vim.schedule` only queues
-- them; nothing about a `-c` argument chain drains that queue on its own.
-- Verified directly: reading `require('telescope.config').values.
-- sorting_strategy` as the very first thing after luafile-ing this file
-- returns telescope's own default ('descending'), not this config's
-- ('ascending'), until something drains the queue.
--
-- Without the explicit `vim.wait(0)` below, the suite happened to pass
-- anyway, but only as a side effect: `vim.pack.get()`'s default
-- `opts.info = true` (used by the "all 13 plugins are installed and
-- active" check, several checks below this line) blocks on real `git`
-- subprocesses to fetch each plugin's info, and that blocking incidentally
-- drains the same libuv queue our scheduled callbacks are sitting in. So
-- the telescope/mini/diffview checks were passing only because an unrelated
-- check's implementation detail ran first -- reorder the checks, or let
-- `vim.pack.get()` grow a fast path that skips `info`, and they would start
-- failing with no code change of their own, looking like a plugin
-- regression rather than a test-ordering artifact. Draining explicitly here
-- removes that dependency.
vim.wait(0)

-- Task 1: core options
check('leader is space', function()
  eq(vim.g.mapleader, ' ', 'mapleader')
end)

check('winborder replaces the hover monkeypatch', function()
  eq(vim.o.winborder, 'single', 'winborder')
end)

check('completeopt enables native fuzzy popup completion', function()
  eq(vim.o.completeopt, 'menu,menuone,noselect,popup,fuzzy', 'completeopt')
end)

-- Rewritten per controller ruling B1: the brief's original version inspected
-- each autocmd's `.command` field, which is always '' for callback-based
-- autocmds (every autocmd in this config uses a callback), so it could never
-- fail. This instead asserts the actual autosave-prevention invariants: the
-- autowrite options are off, and nothing is hooked to the events an autosave
-- would use. Deliberately does NOT check CursorHold/FocusGained, since the
-- external-change augroup legitimately uses those.
--
-- 'matchparen' is Neovim's bundled default-runtime plugin (not part of this
-- config, not an autosave), and it legitimately hooks TextChanged/TextChangedI
-- to redraw the matching-pair highlight. It is excluded by name so this check
-- still bites on anything this config or its plugins add later.
--
-- Ruling S2-T11b (ordering fragility, cannot be fixed here, only recorded):
-- `vim.lsp.completion.enable(..., { autotrigger = true })` (lua/lsp.lua,
-- wired on LspAttach per Task 7) registers a buffer-local InsertLeave
-- autocmd in an `nvim.lsp.completion_<bufnr>` group. This check only passes
-- today because of ORDERING: it runs near the top of this file, before any
-- check that opens a file and triggers LspAttach (the nearest is "lua_ls
-- attaches and native completion is enabled", several hundred lines below).
-- If a future check is inserted ABOVE this one that attaches an LSP client
-- first, this check will start failing -- not because autosave regressed,
-- but because the guarded event list (TextChanged, TextChangedI,
-- InsertLeave) is real Neovim behavior this config cannot avoid. This check
-- must run BEFORE any check that attaches an LSP client; checks appended
-- below it (including this file's own later LSP-attaching checks, and
-- anything appended per this addendum) are fine. If this ever flips to a
-- false failure, the remedy is to exclude the `nvim.lsp.completion_*` group
-- by NAME in the loop below, never to drop InsertLeave from the guarded
-- event list.
check('no autosave options or autocmds exist', function()
  eq(vim.o.autowrite, false, 'autowrite')
  eq(vim.o.autowriteall, false, 'autowriteall')
  for _, ev in ipairs { 'TextChanged', 'TextChangedI', 'InsertLeave' } do
    local found = vim.tbl_filter(function(au)
      return au.group_name ~= 'matchparen'
    end, vim.api.nvim_get_autocmds { event = ev })
    eq(#found, 0, 'autocmd count on ' .. ev)
  end
end)

check('external-change reload is armed', function()
  eq(vim.o.autoread, true, 'autoread')
  eq(vim.o.confirm, true, 'confirm')
  local found = vim.api.nvim_get_autocmds { group = 'external-change' }
  assert(#found > 0, 'no external-change autocmds registered')
end)

check('window navigation maps are not typo-ed', function()
  assert_maps('n', { '<C-h>', '<C-j>', '<C-k>', '<C-l>' })
  local m = find_map('n', '<C-k>')
  eq(norm(m.rhs), norm '<C-w><C-k>', 'C-k rhs')
end)

-- Final-fix item 4: "existing keybinding muscle memory is preserved" is a
-- stated spec success criterion, but of Task 1's preserved set only
-- <C-h/j/k/l> above was ever asserted -- each later task asserted its own
-- additions and nobody came back to own Task 1's surface. Covers the rest
-- of lua/keymaps.lua, read directly from that file rather than assumed:
-- H/L (buffer prev/next), <Esc> (nohlsearch), <leader>bk/bd (buffer kill),
-- <leader>dm (delmarks), <leader>cd, <leader>q (diagnostics to loclist), the
-- '/` mark swap, and terminal-mode <Esc><Esc>. The '/` swap is asserted by
-- rhs, not just lhs existence, since "both keys are bound" alone would not
-- catch the swap being dropped (e.g. both mapped to the same target).
check("Task 1's preserved keybinding surface is intact", function()
  assert_maps('n', {
    'H',
    'L',
    '<Esc>',
    "'",
    '`',
    '<Space>bk',
    '<Space>bd',
    '<Space>dm',
    '<Space>cd',
    '<Space>q',
  })
  assert_maps('t', { '<Esc><Esc>' })

  local quote = find_map('n', "'")
  eq(norm(quote.rhs), norm '`', "' rhs")
  local backtick = find_map('n', '`')
  eq(norm(backtick.rhs), norm "'", '` rhs')
end)

-- Task 2: plugin manifest
local EXPECTED_PLUGINS = {
  'plenary.nvim',
  'telescope.nvim',
  'telescope-fzf-native.nvim',
  'telescope-ui-select.nvim',
  'nvim-treesitter',
  'nvim-lspconfig',
  'lazydev.nvim',
  'gitsigns.nvim',
  'diffview.nvim',
  'conform.nvim',
  'oil.nvim',
  'mini.nvim',
  'nightfox.nvim',
}

check('all 13 plugins are installed and active', function()
  local active = {}
  for _, p in ipairs(vim.pack.get()) do
    if p.active then
      active[p.spec.name] = true
    end
  end
  for _, name in ipairs(EXPECTED_PLUGINS) do
    assert(active[name], 'plugin not active: ' .. name)
  end
end)

check('no plugins beyond the manifest', function()
  local expected = {}
  for _, n in ipairs(EXPECTED_PLUGINS) do
    expected[n] = true
  end
  for _, p in ipairs(vim.pack.get()) do
    assert(expected[p.spec.name], 'unexpected plugin installed: ' .. p.spec.name)
  end
end)

-- Split per controller ruling T2-2: the build product (below) survives on
-- this machine once built, even if the hook that builds it is later deleted
-- from lua/pack.lua, so it alone cannot catch a hook regression. This check
-- instead asserts the hook is wired into the augroup on every startup, which
-- does catch that regression.
check('fzf-native build hook is wired into the PackChanged autocmd', function()
  local autocmds = vim.api.nvim_get_autocmds { group = 'pack-build', event = 'PackChanged' }
  assert(#autocmds > 0, 'no PackChanged autocmd registered in the pack-build augroup')
end)

check('fzf-native build product exists on the runtime path', function()
  local lib = vim.api.nvim_get_runtime_file('build/libfzf.so', false)
  assert(#lib > 0, 'libfzf.so not built -- run scripts/install-tools.sh or reinstall the plugin')
end)

check('lockfile exists at the config root', function()
  local lock = vim.fs.joinpath(vim.fn.stdpath 'config', 'nvim-pack-lock.json')
  assert(vim.uv.fs_stat(lock), 'no lockfile at ' .. lock)
end)

-- Task 3: theme and mini.nvim
check('carbonfox colorscheme is active', function()
  eq(vim.g.colors_name, 'carbonfox', 'colors_name')
end)

check('mini.icons mocks nvim-web-devicons', function()
  assert(package.loaded['nvim-web-devicons'] ~= nil or pcall(require, 'nvim-web-devicons'), 'devicons shim missing')
end)

check('mini.statusline drives the global statusline', function()
  assert(vim.o.statusline:match 'MiniStatusline', 'statusline is ' .. vim.o.statusline)
  eq(vim.o.laststatus, 3, 'laststatus')
end)

check('mini.surround and mini.ai are set up', function()
  assert(_G.MiniSurround, 'MiniSurround global missing')
  assert(_G.MiniAi, 'MiniAi global missing')
end)

-- Task 4: treesitter
local REQUIRED_PARSERS = { 'lua', 'bash', 'go', 'python', 'rust', 'typescript', 'zig', 'typst', 'markdown', 'diff' }

-- Split per controller ruling T4-2: this reads ~/.local/share/nvim-next/site/parser,
-- persistent state OUTSIDE the repo (nvim-treesitter.config.get_installed is a bare
-- vim.fs.dir() over that directory). Once the parsers are built on this machine, this
-- check passes no matter what happens to lua/plugins/treesitter.lua or its init.lua
-- wiring -- it cannot catch a regression in this config, only a missing precondition.
-- It is kept anyway (same shape as the fzf-native build-product check above) because
-- localizing "the parser isn't on disk" to an honest message is useful in its own
-- right. The companion check below is the one that covers the code.
check('required parsers are present in the data dir', function()
  local installed = require('nvim-treesitter.config').get_installed 'parsers'
  local have = {}
  for _, p in ipairs(installed) do
    have[p] = true
  end
  local missing = {}
  for _, p in ipairs(REQUIRED_PARSERS) do
    if not have[p] then
      table.insert(missing, p)
    end
  end
  assert(#missing == 0, 'missing parsers: ' .. table.concat(missing, ', '))
end)

-- Companion to the disk check above: reads lua/plugins/treesitter.lua's own `ensure`
-- list, code state re-evaluated on every startup, so deleting that file or dropping a
-- parser from `ensure` fails this immediately regardless of what is already built on
-- disk.
check('every required parser is in the config ensure list', function()
  local ensure = {}
  for _, p in ipairs(require('plugins.treesitter').ensure) do
    ensure[p] = true
  end
  local missing = {}
  for _, p in ipairs(REQUIRED_PARSERS) do
    if not ensure[p] then
      table.insert(missing, p)
    end
  end
  assert(#missing == 0, 'not in ensure list: ' .. table.concat(missing, ', '))
end)

-- Rewritten per controller ruling T4-1: the original version attached to a
-- `.lua` buffer, which stock Neovim highlights via its own
-- $VIMRUNTIME/ftplugin/lua.lua (a bare vim.treesitter.start()) and bundled
-- lua parser -- independent of this task's FileType autocmd. It passed with
-- lua/plugins/treesitter.lua deleted. `go` has neither a bundled parser nor
-- an auto-starting runtime ftplugin, and the indentexpr assertion is one
-- nothing in stock Neovim sets, so it can only hold if the callback body in
-- lua/plugins/treesitter.lua actually ran.
check('treesitter autocmd arms highlighting and indentexpr', function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'package main' })
  vim.api.nvim_buf_set_name(buf, '/tmp/check_ts.go')
  vim.api.nvim_buf_call(buf, function()
    vim.cmd 'filetype detect'
  end)
  assert(vim.treesitter.highlighter.active[buf], 'no treesitter highlighter attached')
  eq(vim.bo[buf].indentexpr, "v:lua.require'nvim-treesitter'.indentexpr()", 'indentexpr')
end)

-- Task 5: telescope
--
-- Rewritten per addendum-2 Finding 1: `require('telescope').extensions` IS
-- `require('telescope._extensions').manager`, a table whose __index lazily
-- REQUIREs and registers whatever extension name you index -- so indexing
-- `.fzf` / `['ui-select']` auto-loads them on demand, and the old check
-- passed even when this config's `load_extension` calls never ran (verified:
-- it stayed PASS with telescope.lua never required by init.lua). `pairs`
-- only walks the table's already-set raw keys and never triggers `__index`,
-- so it discriminates "actually loaded" from "loadable on demand".
check('telescope extensions are actually loaded (not just lazily indexable)', function()
  local manager = require('telescope._extensions').manager
  local loaded = {}
  for name in pairs(manager) do
    loaded[name] = true
  end
  assert(loaded.fzf, 'fzf extension not actually loaded (registry key absent before indexing)')
  assert(loaded['ui-select'], 'ui-select extension not actually loaded (registry key absent before indexing)')
end)

-- Companion check for Ruling S2-T5a: proves setup{} was applied by reading
-- values back from telescope's own resolved config, not from the table this
-- config wrote. sorting_strategy defaults to 'descending' and
-- layout_config.prompt_position defaults to nil, so both fail if
-- plugins.telescope's setup{} call never ran.
--
-- Deferred minor (Task 11 addendum section 4, must-fix): layout_strategy's
-- assertion below ('horizontal') matches telescope's own default, so it
-- discriminates nothing on its own -- it would pass even with that key
-- deleted from plugins.telescope's setup{} call. It is kept for readability
-- (it names the strategy the other two assertions' values are relative to),
-- but the sorting_strategy and layout_config.prompt_position assertions are
-- the ones actually carrying this check's weight. Do not "simplify" them
-- away.
check("telescope setup{} took effect, per telescope's own resolved config", function()
  local values = require('telescope.config').values
  eq(values.sorting_strategy, 'ascending', 'sorting_strategy')
  eq(values.layout_strategy, 'horizontal', 'layout_strategy')
  eq(values.layout_config.prompt_position, 'top', 'layout_config.prompt_position')
end)

check('telescope keymaps are bound', function()
  assert_maps('n', {
    '<Space><Space>',
    '<Space>fg',
    '<Space>fw',
    '<Space>fh',
    '<Space>fk',
    '<Space>fs',
    '<Space>fb',
    '<Space>fc',
    '<Space>fd',
    '<Space>fr',
    '<Space>/',
  })
end)

-- Rewritten per addendum-2 Finding 2: find_files() reports failures
-- asynchronously through autocmd callbacks rather than raising, so a bare
-- pcall around it (as the brief's version amounted to) returns ok=true even
-- while the picker is erroring to stderr -- the check passed unconditionally.
-- The brief's `nvim_input '<Esc>'` is also queued input that never drains in
-- a headless script. This instead asserts real proof the picker constructed
-- (a TelescopePrompt buffer now exists and is current) and closes it
-- synchronously through telescope's own actions.close, the same function its
-- normal <Esc> mapping calls, rather than via queued input -- so later
-- checks run against a clean buffer/window state. Note this still only
-- proves construction, not that our setup{} config shaped the picker; that
-- is covered by the checks above.
check('find_files picker actually constructs (buffer proof, not a no-raise smoke test)', function()
  require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
  local prompt_bufnr = vim.api.nvim_get_current_buf()
  eq(vim.bo[prompt_bufnr].filetype, 'TelescopePrompt', 'filetype of buffer opened by find_files')
  require('telescope.actions').close(prompt_bufnr)
end)

-- Addendum-2 Finding 3: pins the fix to lua/plugins/treesitter.lua's FileType
-- guard. The old guard pcall'd vim.treesitter.language.add(lang), but for a
-- parserless filetype like "TelescopePrompt", get_lang falls back to
-- returning the filetype itself and language.add "succeeds" (returns
-- nil/false, does not error) -- it is vim.treesitter.start that then raises
-- "Parser could not be created for buffer N and language ...". The guard
-- therefore guarded the wrong call and every telescope picker printed an
-- error traceback on open. This check reproduces the exact trigger (a buffer
-- whose filetype is "TelescopePrompt") without opening a real picker, and
-- asserts no error surfaces and no highlighter attaches.
check('FileType autocmd does not error on a parserless filetype (TelescopePrompt)', function()
  -- Setting a buffer-local option fires its FileType autocmd through
  -- Neovim's option-set machinery, which itself catches Lua callback
  -- errors and reports them via `:messages`/v:errmsg rather than
  -- propagating them to this Lua call site -- so a bare pcall around the
  -- assignment cannot observe the bug (verified: it stayed ok=true with
  -- the old buggy guard restored). v:errmsg is where that swallowed error
  -- surfaces, so clear it first and assert it is still empty afterwards.
  vim.v.errmsg = ''
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = 'TelescopePrompt'
  assert(vim.v.errmsg == '', 'FileType autocmd raised: ' .. vim.v.errmsg)
  assert(not vim.treesitter.highlighter.active[buf], 'treesitter highlighter attached to a parserless buffer')
end)

-- Task 6: toolchain
--
-- Per addendum Ruling A15: the brief's own list (eleven entries) omits gofmt
-- and rustfmt, which Task 8 configures as conform formatters -- without them
-- listed here, a machine missing rustfmt would pass this suite and only fail
-- silently at format-on-save time in Task 8. Thirteen entries total: the nine
-- servers Task 7 enables by name plus the five formatter binaries Task 8
-- uses (stylua, ruff, gofmt, rustfmt, prettier; ruff appears once even though
-- Task 8 calls it under three conform names).
--
-- Same shape as the treesitter disk check reworked in Task 4: this asserts
-- machine state OUTSIDE the repo (the system PATH), not code in this repo.
-- It cannot catch a regression in install-tools.sh itself -- delete that
-- script entirely and this check still passes, because it only looks at
-- whether the binaries are already present on this machine from some prior
-- run. That is accepted here because install-tools.sh was run twice back to
-- back during Task 6 and produced the same PATH state both times, with no
-- error or duplicate work on the second run -- idempotence this suite has no
-- way to re-check on a machine where the tools are already installed, and
-- there is no meaningful in-repo "code state" to assert against for a
-- system-toolchain installer.
check('every language server and formatter is on PATH', function()
  local tools = {
    'lua-language-server',
    'bash-language-server',
    'gopls',
    'ruff',
    'ty',
    'rust-analyzer',
    'typescript-language-server',
    'zls',
    'tinymist',
    'stylua',
    'prettier',
    'gofmt',
    'rustfmt',
  }
  local missing = {}
  for _, t in ipairs(tools) do
    if vim.fn.executable(t) ~= 1 then
      table.insert(missing, t)
    end
  end
  assert(#missing == 0, 'not on PATH: ' .. table.concat(missing, ', ') .. ' -- run scripts/install-tools.sh')
end)

-- Task 7: LSP
-- Rewritten per Ruling T7-1: `vim.lsp.config[name]` lazily resolves
-- nvim-lspconfig's `lsp/<name>.lua` data straight from the runtimepath,
-- completely independent of whether `vim.lsp.enable{}` was ever called --
-- verified empirically by wrapping lua/lsp.lua's `vim.lsp.enable{}` call in
-- `if false then ... end` and confirming `vim.lsp.config['gopls'].cmd` still
-- resolved. The old assertion (`cfg and cfg.cmd`) therefore could not fail
-- even if the entire enable block were deleted. `vim.lsp.is_enabled(name)`
-- is the real discriminator: its own docstring in $VIMRUNTIME/lua/vim/lsp.lua
-- (~line 672) says it "does not have the side-effect of resolving the
-- config", and it reads `lsp._enabled_configs[name]`, a table written only
-- by `vim.lsp.enable()`.
--
-- The negative control on 'pyright' (shipped by nvim-lspconfig, resolvable
-- via vim.lsp.config exactly like the nine we use, but never passed to
-- vim.lsp.enable) is what stops this check from quietly reverting to a
-- tautology: if a future edit swaps `is_enabled` back for something true of
-- every lspconfig server, the control catches it even if the positive
-- assertions above it do not.
check('nine servers are actually enabled, not merely resolvable', function()
  local want = { 'lua_ls', 'bashls', 'gopls', 'ruff', 'ty', 'rust_analyzer', 'ts_ls', 'zls', 'tinymist' }
  for _, name in ipairs(want) do
    assert(vim.lsp.is_enabled(name), name .. ' is not enabled (vim.lsp.is_enabled == false)')
  end
  assert(vim.lsp.is_enabled 'pyright' == false, 'negative control failed: pyright should not be enabled -- this check may have reverted to a tautology')
end)

-- Rewritten per addendum Ruling B7(a): the brief's version asserted only
-- that cfg.virtual_text was truthy, which would still pass if warnings,
-- hints and info all rendered inline too -- the exact opposite of what this
-- check's name ("for errors only") and lua/lsp.lua's own comment claim it
-- prevents. Assert the severity restriction itself.
check('diagnostics show virtual text for errors only', function()
  local cfg = vim.diagnostic.config()
  assert(
    cfg.virtual_text and cfg.virtual_text.severity and cfg.virtual_text.severity.min == vim.diagnostic.severity.ERROR,
    'virtual_text is not restricted to severity.min == ERROR'
  )
  assert(cfg.severity_sort, 'severity_sort off')
end)

-- Rewritten per addendum Ruling B7(b): the brief's version asserted
-- `vim.lsp.completion.get and true` (proves only that the stdlib module
-- exists -- it always does, whether or not this config calls it) and
-- omnifunc == 'v:lua.vim.lsp.omnifunc' (set by ANY LSP attach, by Neovim
-- itself, regardless of whether vim.lsp.completion.enable ran). Neither
-- proves lua/lsp.lua's `vim.lsp.completion.enable(true, client.id, ev.buf,
-- { autotrigger = true })` call actually executed.
--
-- Verified against $VIMRUNTIME/lua/vim/lsp/completion.lua on this machine:
-- get_augroup(bufnr) (get_augroup local fn) names the group
-- 'nvim.lsp.completion_<bufnr>' (line ~613), and only when opts.autotrigger
-- is true (lines ~1175-1187) does enable() register buffer-local
-- InsertCharPre and InsertLeave autocmds in that group. That is the real
-- behavioural proof: assert the group's autocmds exist and include
-- InsertCharPre. (nvim_get_autocmds's buffer filter key is `buffer`, not
-- `buf` -- verified directly: `buffer = <invalid id>` raises, `buf =
-- <invalid id>` is silently ignored -- so `buffer` is used below; the group
-- name alone already scopes the query to this exact bufnr.) Let
-- nvim_get_autocmds throw if the group does not exist -- that is this check
-- failing correctly, not something to pcall away.
check('lua_ls attaches and native completion is enabled', function()
  local file = vim.fs.joinpath(vim.fn.stdpath 'config', 'init.lua')
  vim.cmd.edit(file)
  local buf = vim.api.nvim_get_current_buf()
  vim.wait(20000, function()
    return #vim.lsp.get_clients { bufnr = buf } > 0
  end, 200)
  local clients = vim.lsp.get_clients { bufnr = buf }
  assert(#clients > 0, 'no LSP client attached to init.lua after 20s')

  local autocmds = vim.api.nvim_get_autocmds { group = 'nvim.lsp.completion_' .. buf, buffer = buf }
  assert(#autocmds > 0, 'no autocmds registered in the nvim.lsp.completion_' .. buf .. ' augroup')
  local has_insert_char_pre = false
  for _, au in ipairs(autocmds) do
    if au.event == 'InsertCharPre' then
      has_insert_char_pre = true
    end
  end
  assert(has_insert_char_pre, 'completion augroup has no InsertCharPre autocmd -- autotrigger was not enabled')

  -- Secondary signal only, per the addendum -- not the evidence above.
  assert(vim.bo[buf].omnifunc == 'v:lua.vim.lsp.omnifunc', 'omnifunc not set by LSP attach')
end)

-- Strengthened per the task-7 review's Minor finding: assert_maps only checks
-- that an lhs exists, never what it does -- a broken implementation binding
-- `gd` to the wrong function would still pass. `gd` and `gD` are bound to
-- stable, addressable function references (telescope.builtin.lsp_definitions
-- and vim.lsp.buf.declaration respectively), so their callback identity can
-- be asserted directly. `<Space>th` is left existence-only on purpose: its
-- rhs in lua/lsp.lua is `function() ... end`, a fresh closure allocated on
-- every LspAttach, so no two calls ever produce the same function value --
-- identity comparison there would be meaningless, not a stronger check.
check('gd and inlay-hint toggle are bound in an LSP buffer', function()
  local buf = vim.api.nvim_get_current_buf()
  assert_maps('n', { 'gd', 'gD' }, buf)
  local gd = vim.fn.maparg('gd', 'n', false, true)
  eq(gd.callback, require('telescope.builtin').lsp_definitions, 'gd callback identity')
  local gD = vim.fn.maparg('gD', 'n', false, true)
  eq(gD.callback, vim.lsp.buf.declaration, 'gD callback identity')
  -- lua_ls advertises inlay hints; if a future server does not, scope this check.
  assert_maps('n', { '<Space>th' }, buf)
end)

-- Task 8: formatting
check('format keymap is <leader>F, not <leader>f', function()
  assert_maps('n', { '<Space>F' })
  assert(not find_map('n', '<Space>f'), '<leader>f is bound, which would delay every telescope picker')
end)

check('formatters are configured for the supported languages', function()
  local by_ft = require('conform').formatters_by_ft
  for _, ft in ipairs { 'lua', 'python', 'typescript', 'json', 'yaml', 'go', 'rust' } do
    assert(by_ft[ft], 'no formatter for ' .. ft)
  end
end)

-- Genuine end-to-end proof, per addendum ruling S2-T8a: writes a real file,
-- saves it through the real BufWritePre path, and asserts the resulting
-- bytes -- not just that some config table looks right. Cleanup is
-- unconditional (runs whether the assertion passes or fails) so a failing
-- run does not leave /tmp/check_fmt.lua behind for the next run to trip on.
check('format on save rewrites a badly formatted lua file', function()
  local path = '/tmp/check_fmt.lua'
  vim.fn.writefile({ 'local   x    =    1' }, path)
  vim.cmd.edit(path)
  -- `silent` only suppresses the "written" message (which otherwise runs
  -- into the next check's PASS line under --headless, per addendum section
  -- 4's must-fix on one-check-per-line output); BufWritePre still fires the
  -- same way.
  vim.cmd 'silent write'
  vim.wait(5000, function()
    return vim.fn.readfile(path)[1] ~= 'local   x    =    1'
  end, 100)
  local ok, err = pcall(eq, vim.fn.readfile(path)[1], 'local x = 1', 'formatted line')
  vim.fn.delete(path)
  if not ok then
    error(err, 0)
  end
end)

-- Task 9: git review
--
-- Ruling B9: <leader>gp (preview hunk, deviation D3) is bound only inside
-- gitsigns' on_attach in the brief's config, with no global fallback (unlike
-- its five siblings) and no entry in this assertion list -- so the one key
-- the plan went out of its way to add was the one key nothing verified.
-- Fixed in lua/plugins/gitsigns.lua (global fallback added) and here.
check('git review keymaps are bound (global fallbacks)', function()
  assert_maps('n', {
    '<Space>gd',
    '<Space>gD',
    '<Space>gh',
    '<Space>gq',
    '<Space>gb',
    '<Space>gs',
    '<Space>gr',
    '<Space>gp',
    ']c',
    '[c',
  })
end)

-- Rewritten per controller ruling S2-T9a: diffview registers DiffviewOpen and
-- DiffviewFileHistory from its own plugin/ directory the moment vim.pack adds
-- the package, entirely independent of require('diffview').setup{} --
-- controller-verified true even with lua/plugins/diffview.lua deleted
-- outright. So the command-registration assertion alone proves only that
-- Task 2 installed the plugin, which the "all 13 plugins" check already
-- covers, and would pass with this whole file deleted. Kept below as a cheap
-- sanity check, but the real evidence is reading diffview's own resolved
-- config: enhanced_diff_hl defaults to false and view.merge_tool.layout
-- defaults to 'diff3_horizontal' (both measured on this machine before this
-- task existed), and the brief's setup{} call sets both away from those
-- defaults.
check("diffview setup{} took effect, per diffview's own resolved config", function()
  local cmds = vim.api.nvim_get_commands {}
  assert(cmds.DiffviewOpen, 'DiffviewOpen not registered')
  assert(cmds.DiffviewFileHistory, 'DiffviewFileHistory not registered')

  local cfg = require('diffview.config').get_config()
  eq(cfg.enhanced_diff_hl, true, 'enhanced_diff_hl')
  eq(cfg.view.merge_tool.layout, 'diff3_mixed', 'view.merge_tool.layout')
end)

-- Ruling S2-T9b: the global fallbacks asserted above are bound at
-- require-time regardless of on_attach, so a suite that only checked those
-- could not catch on_attach being deleted, or every buffer-local map() call
-- inside it breaking -- and on_attach is where the hunk navigation this
-- config exists for actually lives. This opens a real file in this git
-- repository, waits for gitsigns to attach (vim.b.gitsigns_head is set only
-- by a successful attach), and asserts the buffer-local maps that only
-- on_attach creates. Both this check and the global-fallback check above are
-- kept deliberately: one proves the fallbacks that non-git buffers and this
-- suite see, the other proves on_attach itself actually ran.
--
-- Not asserted anywhere: gitsigns' sign text (signs.add.text etc). Controller
-- measured gitsigns' own default signs.add.text as already '┃', byte-
-- identical to what the brief's setup{} sets -- an assertion on it would
-- discriminate nothing and would be an eighth vacuous check on this branch.
check('gitsigns attaches in a git repository and binds buffer-local hunk maps', function()
  vim.cmd.edit(vim.fs.joinpath(vim.fn.stdpath 'config', 'init.lua'))
  local buf = vim.api.nvim_get_current_buf()
  vim.wait(3000, function()
    return vim.b.gitsigns_head ~= nil
  end, 100)
  assert(vim.b.gitsigns_head, 'gitsigns did not attach')
  assert_maps('n', { ']c', '[c', '<Space>gs', '<Space>gr', '<Space>gp', '<Space>gb' }, buf)
end)

-- Final-fix item 1: the two checks above only exercise gitsigns' buffer-local
-- ]c/[c (attached, inside this repo) and the mere existence of the global
-- fallback lhs -- neither calls the global fallback's callback in the one
-- situation where it used to matter: a diff-mode window gitsigns has not
-- attached to. lua/plugins/gitsigns.lua's global fallbacks used to call
-- gs.nav_hunk unconditionally, so in exactly that situation -- diffview's
-- base pane, or plain `nvim -d` -- they silently no-opped over Vim's builtin
-- ]c, instead of falling through to it the way the buffer-local maps in
-- on_attach always have.
--
-- This reproduces that situation headless without diffview (whose own window
-- scheduling is awkward to drive headless) but with real Vim diff mode, not
-- a mock: two /tmp files -- outside any git repo, so gitsigns never attaches
-- (verified below via vim.b.gitsigns_head) -- opened with `:diffsplit`, which
-- sets the window-local 'diff' option the same way `nvim -d` does. maparg
-- resolves ']c' to the global fallback here because no buffer-local map
-- exists for a /tmp scratch file. Verified directly against the pre-fix
-- code (gs.nav_hunk unconditional): this check fails, cursor stays on line
-- 1, because gitsigns finds no attached buffer to navigate and does nothing.
check('global ]c fallback falls through to Vim builtin diff nav when gitsigns has not attached', function()
  local path_a = '/tmp/check_diffnav_a.txt'
  local path_b = '/tmp/check_diffnav_b.txt'
  vim.fn.writefile({ 'one', 'two', 'three' }, path_a)
  vim.fn.writefile({ 'one', 'two', 'THREE' }, path_b)

  vim.cmd.edit(path_a)
  local win_a = vim.api.nvim_get_current_win()
  local buf_a = vim.api.nvim_get_current_buf()
  vim.cmd('vertical diffsplit ' .. vim.fn.fnameescape(path_b))
  local win_b = vim.api.nvim_get_current_win()

  local ok, err = pcall(function()
    vim.api.nvim_set_current_win(win_a)
    assert(vim.wo.diff, 'win_a is not in diff mode')
    assert(vim.b.gitsigns_head == nil, 'gitsigns unexpectedly attached to a /tmp scratch file')
    vim.api.nvim_win_set_cursor(win_a, { 1, 0 })

    local map = vim.fn.maparg(']c', 'n', false, true)
    assert(map.callback, 'global ]c has no callback')
    map.callback()

    local cursor = vim.api.nvim_win_get_cursor(win_a)
    eq(cursor[1], 3, 'cursor line after invoking the global ]c callback in a diff-mode window gitsigns has not attached to')
  end)

  -- Cleanup is unconditional, same reasoning as the format-on-save check
  -- above: a failing run must not leave windows/buffers/files behind for the
  -- next run to trip on.
  vim.cmd 'diffoff!'
  pcall(vim.api.nvim_win_close, win_b, true)
  pcall(vim.api.nvim_buf_delete, buf_a, { force = true })
  vim.fn.delete(path_a)
  vim.fn.delete(path_b)

  if not ok then
    error(err, 0)
  end
end)

-- Task 10: oil
check('- opens oil', function()
  assert_maps('n', { '-' })
end)

-- Per addendum ruling S2-T10a: the buffer-filetype assertion alone proves
-- oil's setup{} ran at all (oil registers :Oil and only works once setup()
-- has been called -- controller-verified require('oil').open() errors
-- outright without it), but not that it ran with the options this config
-- intends.
--
-- Corrected in Task 11 (the controller's own error, caught by the Task 10
-- review): S2-T10a additionally claimed default_file_explorer was a second
-- discriminator, on the premise that oil/config.lua's module table starts
-- with it nil/false before setup(). That premise is wrong -- oil's own
-- default_config.default_file_explorer is already `true` (oil/config.lua:4)
-- -- so `default_file_explorer = true` staying in lua/plugins/oil.lua is
-- correct and meaningful there, but asserting it back here discriminates
-- nothing: the check would still pass with that line deleted from the
-- config entirely. That assertion is removed. view_options.show_hidden is
-- the one genuine discriminator that survives: oil's own default is
-- `false` (oil/config.lua:82), so it really does catch this config's
-- setup{} not having run. prompt_save_on_select_new_entry is excluded for
-- the same reason default_file_explorer now is: oil's own default for it is
-- already `true`, identical to the value this config sets (the same trap as
-- gitsigns' sign text in Task 9).
check('oil renders a directory as a buffer, with our setup{} config applied', function()
  require('oil').open(vim.fn.stdpath 'config')
  vim.wait(3000, function()
    return vim.bo.filetype == 'oil'
  end, 100)
  eq(vim.bo.filetype, 'oil', 'oil buffer filetype')
  local cfg = require 'oil.config'
  eq(cfg.view_options.show_hidden, true, 'view_options.show_hidden')
  vim.cmd 'bwipeout!'
end)

-- Task 11: health and the final gate.
--
-- These two run last (see Ruling S2-T11b above the autosave check for why
-- ordering matters in this file): neither attaches an LSP client or does
-- anything else that would disturb an earlier check's preconditions.
check('no deprecated API warnings at startup', function()
  local messages = vim.api.nvim_exec2('messages', { output = true }).output
  assert(not messages:match 'deprecated', 'deprecation warning in :messages\n' .. messages)
end)

-- Rewritten per Ruling B11 (pre-flight, binding): the brief's version called
-- vim.cmd.checktime() directly, which tests Neovim's built-in primitive, not
-- this config's own `external-change` augroup (lua/autocmds.lua) -- that
-- autocmd wiring could be deleted outright and the brief's check would still
-- pass. This also closes a Task 1 deferred minor: the "external-change
-- reload is armed" check above only asserts the augroup is non-empty, never
-- that its autocmds do anything -- this is the check that proves they do.
--
-- Firing a real FocusGained event turned out to be necessary but NOT
-- sufficient to observe a reloaded buffer, and this took real digging to
-- find: `:h :checktime` says plainly "If this is called from an
-- autocommand ... the actual check is postponed until a moment the side
-- effects would be harmless" -- and our own callback calls it from inside
-- an autocommand, every time, by construction. Empirically (see the task
-- report) that postponement never resolves inside a single --headless run:
-- CursorHold, which is driven by the identical idle mechanism, never fires
-- headless either, even across a real 2-second vim.wait with nothing else
-- happening. Redraw, sleep, feedkeys, nvim_input, getchar, firing the event
-- five times in a row, and splitting the fire and the read across two
-- separate -c blocks were all tried and none flush it. So the buffer's
-- *content* cannot be asserted here.
--
-- The tempting fix -- call vim.cmd.checktime() again ourselves, directly,
-- to force the flush -- was tried and rejected on purpose: called directly
-- (not from an autocommand) it is NOT postponed, so it reloads the file on
-- its own regardless of whether the config's autocmd exists at all. That
-- reintroduces exactly the tautology this ruling exists to close.
--
-- Instead: spy on vim.cmd.checktime for the duration of firing the event.
-- This proves the thing Ruling B11 actually cares about -- that a real
-- FocusGained event drives execution into this config's own callback, which
-- calls checktime() -- without depending on a side effect Neovim's own
-- postponement rules make unobservable here. Verified directly during Task
-- 11: deleting the external-change autocmd entirely, and separately editing
-- its guard to `mode() == 'c'` (inverting it) so it rejects this context,
-- both made this check fail with "firing FocusGained did not call
-- checktime"; restoring either one made it pass again.
--
-- /tmp/check_reload.txt (not the scratchpad) is deliberate, per the Task 8
-- precedent: this is committed test code and must work on any machine, for
-- years, not just this session.
check('external change fires the external-change autocmd, which calls checktime', function()
  local path = '/tmp/check_reload.txt'
  vim.fn.writefile({ 'before' }, path)
  vim.cmd.edit(path)
  vim.fn.writefile({ 'after' }, path)

  local called = false
  local orig_checktime = vim.cmd.checktime
  vim.cmd.checktime = function(...)
    called = true
    return orig_checktime(...)
  end
  local ok, err = pcall(vim.api.nvim_exec_autocmds, 'FocusGained', {})
  vim.cmd.checktime = orig_checktime
  vim.fn.delete(path)

  assert(ok, err)
  assert(called, 'firing FocusGained did not call checktime -- external-change autocmd missing or its guard rejected this context')
end)

out ''
out(string.format('%d failure(s)', failed))
if failed > 0 then
  vim.cmd 'cq 1'
end
