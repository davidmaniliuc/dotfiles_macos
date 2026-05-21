return {
  'nvimdev/indentmini.nvim',
  config = function()
    require('indentmini').setup() -- use default config
    -- Colors are applied automatically based on user-defined highlight groups.
    -- There is no default value.
    vim.cmd.highlight 'IndentLine guifg=#353535'
    -- Current indent line highlight
    vim.cmd.highlight 'IndentLineCurrent guifg=#78a9ff'
  end,
}
