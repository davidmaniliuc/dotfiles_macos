require('lazy').setup {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  require 'kickstart/plugins/telescope',

  require 'kickstart/plugins/lspconfig',

  require 'kickstart/plugins/conform',

  require 'kickstart/plugins/cmp',

  require 'kickstart/plugins/treesitter',

  require 'themes.carbonfox',

  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',

  require 'kickstart.plugins.gitsigns',

  require 'kickstart.plugins.autopairs',

  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  { import = 'custom.plugins' },
  --
}

-- vim: ts=2 sts=2 sw=2 et
