return {
  {
    'nvim-mini/mini.nvim',
    version = false,
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup { n_lines = 500 }

      local MiniFiles = require 'mini.files'
      MiniFiles.setup {
        options = {
          permanent_delete = false,
          use_as_default_explorer = true,
        },
        mappings = {
          show_help = 'g?',
          synchronize = 'gs',
        },
        windows = {
          preview = true,
          width_focus = 50,
          width_nofocus = 50,
          width_preview = 50,
        },
      }

      local map = vim.keymap.set

      map('n', '<leader>e', function()
        if not MiniFiles.close() then
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        end
      end, { desc = 'Toggle MiniFiles (Current File)' })

      map('n', '<leader>er', MiniFiles.open, { desc = 'MiniFiles Open (CWD)' })
    end,
  },
}
