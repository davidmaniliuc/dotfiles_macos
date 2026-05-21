return {
  'windwp/nvim-ts-autotag',
  lazy = true,
  ft = { 'html', 'javascriptreact', 'typescriptreact', 'vue', 'xml' },
  config = function()
    require('nvim-ts-autotag').setup()
  end,
}
