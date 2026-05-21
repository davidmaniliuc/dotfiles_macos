return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },

  config = function()
    vim.opt.termguicolors = true
    vim.o.mousemoveevent = true

    require('bufferline').setup {
      options = {
        separator_style = 'slant',

        max_name_length = 18,
        tab_size = 18,

        hover = {
          enabled = true,
          delay = 100,
          reveal = { 'close' },
        },

        indicator = {
          style = 'none',
        },

        name_formatter = function(buf)
          -- Add a space before the name
          return ' ' .. vim.fn.fnamemodify(buf.name, ':t')
        end,
      },
      highlights = {
        buffer_selected = {
          italic = false,
        },
      },
    }

    function _G.toggle_bar()
      if vim.o.showtabline == 2 then
        vim.o.showtabline = 0
      else
        vim.o.showtabline = 2
      end
    end

    vim.keymap.set('n', '<A-Tab>', toggle_bar, { noremap = true, silent = true })
  end,
}
