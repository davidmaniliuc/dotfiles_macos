-- Port of Helix's term16_dark theme (runtime/themes/term16_dark.toml).
--
-- Like the original, it uses only the terminal's 16 ANSI colors, so it follows
-- whatever palette the terminal is set to. That only works with
-- termguicolors off: with it on, Neovim ignores cterm colors entirely.
--
-- Helix's "dim" modifier has no Neovim equivalent and is dropped.

vim.cmd 'highlight clear'
vim.o.termguicolors = false
vim.o.background = 'dark'
vim.g.colors_name = 'term16_dark'

-- Helix color names -> ANSI indices (Helix's "gray" is bright black).
local c = {
  black = 0,
  red = 1,
  green = 2,
  yellow = 3,
  blue = 4,
  magenta = 5,
  cyan = 6,
  light_gray = 7,
  gray = 8,
  light_red = 9,
  light_green = 10,
  light_yellow = 11,
  light_blue = 12,
  light_magenta = 13,
  light_cyan = 14,
  white = 15,
}

local function hl(name, spec)
  local s = {}
  for k, v in pairs(spec) do
    if k == 'fg' then
      s.ctermfg = v
    elseif k == 'bg' then
      s.ctermbg = v
    elseif k == 'link' then
      s.link = v
    else
      s.cterm = s.cterm or {}
      s.cterm[k] = v
    end
  end
  vim.api.nvim_set_hl(0, name, s)
end

local groups = {
  -- UI. No background anywhere the Helix theme leaves it empty.
  Normal = { fg = c.white },
  NormalFloat = { bg = c.black },
  FloatBorder = { fg = c.gray, bg = c.black },
  WinSeparator = { fg = c.red },
  Cursor = { reverse = true },
  CursorLine = { bg = c.black },
  CursorColumn = { bg = c.black },
  ColorColumn = { bg = c.black },
  CursorLineNr = { fg = c.white, bg = c.black, bold = true },
  LineNr = { fg = c.gray, bold = true },
  SignColumn = {},
  FoldColumn = { fg = c.gray },
  Folded = { fg = c.light_gray, bg = c.black },
  MatchParen = { fg = c.light_yellow, reverse = true },
  Visual = { bg = c.gray },
  Search = { fg = c.black, bg = c.light_yellow },
  IncSearch = { fg = c.black, bg = c.light_cyan },
  CurSearch = { link = 'IncSearch' },
  Pmenu = { fg = c.light_gray, bg = c.gray },
  PmenuSel = { reverse = true },
  PmenuSbar = { bg = c.gray },
  PmenuThumb = { bg = c.light_blue },
  StatusLine = { fg = c.light_gray, bg = c.gray },
  StatusLineNC = { fg = c.light_gray, bg = c.black },
  TabLine = { fg = c.light_gray, bg = c.gray },
  -- No bg: Neovim fills every tabline cell lacking its own bg with this group,
  -- so a bg here would also paint the selected tab. BufferLineFill sets the bar.
  TabLineFill = {},
  TabLineSel = { fg = c.white, bold = true },
  NonText = { fg = c.gray },
  Whitespace = { fg = c.gray },
  SpecialKey = { fg = c.gray },
  EndOfBuffer = { fg = c.black },
  Directory = { fg = c.light_blue },
  Title = { fg = c.light_blue, bold = true },
  Question = { fg = c.light_green },
  MoreMsg = { fg = c.light_green },
  ModeMsg = { fg = c.white, bold = true },
  ErrorMsg = { fg = c.light_red },
  WarningMsg = { fg = c.yellow },
  LspInlayHint = { fg = c.light_gray, italic = true },

  -- Syntax
  Comment = { fg = c.light_gray, italic = true },
  Constant = { fg = c.light_yellow, bold = true },
  String = { fg = c.light_green },
  Character = { fg = c.light_green },
  Number = { fg = c.light_yellow },
  Float = { fg = c.light_yellow },
  Boolean = { fg = c.light_yellow, bold = true },
  Identifier = { fg = c.white },
  Function = { fg = c.light_blue },
  Statement = { fg = c.light_magenta },
  Keyword = { fg = c.light_magenta },
  Conditional = { fg = c.light_magenta },
  Repeat = { fg = c.light_magenta },
  Exception = { fg = c.light_red },
  Operator = { fg = c.light_blue, bold = true },
  PreProc = { fg = c.light_yellow, bold = true },
  Macro = { fg = c.light_red },
  Type = { fg = c.blue },
  Special = { fg = c.light_red },
  SpecialChar = { fg = c.light_cyan },
  Tag = { fg = c.light_magenta },
  Delimiter = { fg = c.white },
  Underlined = { underline = true },
  Error = { fg = c.light_red },
  Todo = { fg = c.black, bg = c.light_yellow, bold = true },

  -- Tree-sitter
  ['@variable'] = { fg = c.white },
  ['@variable.builtin'] = { fg = c.light_red },
  ['@variable.parameter'] = { fg = c.light_yellow, italic = true },
  ['@variable.member'] = { fg = c.light_green },
  ['@property'] = { fg = c.light_green },
  ['@constant'] = { link = 'Constant' },
  ['@constant.builtin'] = { fg = c.light_yellow, bold = true },
  ['@string.escape'] = { fg = c.light_cyan },
  ['@string.special.url'] = { fg = c.magenta, underline = true },
  ['@constructor'] = { fg = c.light_blue },
  ['@function.builtin'] = { fg = c.light_blue, bold = true },
  ['@function.macro'] = { fg = c.light_red },
  ['@type.builtin'] = { fg = c.blue, bold = true },
  ['@module'] = { fg = c.blue },
  ['@label'] = { fg = c.light_green },
  ['@attribute'] = { fg = c.light_yellow },
  ['@keyword.operator'] = { fg = c.light_blue, bold = true },
  ['@keyword.exception'] = { fg = c.light_red },
  ['@keyword.directive'] = { fg = c.light_yellow, bold = true },
  ['@tag'] = { fg = c.light_magenta },
  ['@tag.attribute'] = { fg = c.light_yellow },
  ['@punctuation'] = { fg = c.white },

  -- Markup
  ['@markup.heading'] = { fg = c.light_blue, bold = true },
  ['@markup.list'] = { fg = c.light_red },
  ['@markup.strong'] = { fg = c.light_cyan, bold = true },
  ['@markup.italic'] = { fg = c.light_blue, italic = true },
  ['@markup.strikethrough'] = { strikethrough = true },
  ['@markup.link'] = { fg = c.light_magenta },
  ['@markup.link.url'] = { fg = c.magenta, underline = true },
  ['@markup.quote'] = { fg = c.light_cyan },
  ['@markup.raw'] = { fg = c.light_green },

  -- Diff and git
  DiffAdd = { fg = c.light_green },
  DiffChange = { fg = c.light_yellow },
  DiffDelete = { fg = c.light_red },
  DiffText = { fg = c.black, bg = c.light_yellow },
  Added = { fg = c.light_green },
  Changed = { fg = c.light_yellow },
  Removed = { fg = c.light_red },
  GitSignsAdd = { fg = c.light_green },
  GitSignsChange = { fg = c.light_yellow },
  GitSignsDelete = { fg = c.light_red },

  -- Diagnostics
  DiagnosticError = { fg = c.light_red },
  DiagnosticWarn = { fg = c.yellow },
  DiagnosticInfo = { fg = c.light_cyan },
  DiagnosticHint = { fg = c.light_gray },
  DiagnosticOk = { fg = c.light_green },
  DiagnosticUnderlineError = { undercurl = true },
  DiagnosticUnderlineWarn = { undercurl = true },
  DiagnosticUnderlineInfo = { undercurl = true },
  DiagnosticUnderlineHint = { undercurl = true },

  -- Bufferline only derives its colors from gui values, so give it cterm ones.
  BufferLineFill = { bg = c.gray },
  BufferLineBackground = { fg = c.light_gray, bg = c.gray },
  BufferLineBufferVisible = { fg = c.light_gray, bg = c.gray },
  BufferLineBufferSelected = { fg = c.white, bold = true },
  BufferLineSeparator = { fg = c.gray, bg = c.gray },
  BufferLineSeparatorVisible = { fg = c.gray, bg = c.gray },
  BufferLineSeparatorSelected = { fg = c.gray },
  BufferLineCloseButton = { fg = c.light_gray, bg = c.gray },
  BufferLineCloseButtonSelected = { fg = c.light_red },
  BufferLineModified = { fg = c.light_green, bg = c.gray },
  BufferLineModifiedSelected = { fg = c.light_green },
}

for name, spec in pairs(groups) do
  hl(name, spec)
end

-- Terminal buffers use the terminal's own palette.
for i = 0, 15 do
  vim.g['terminal_color_' .. i] = nil
end
