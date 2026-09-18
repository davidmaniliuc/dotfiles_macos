-- The buffer tabs across the top. Carried over from the previous config.
--
-- Deferred with vim.schedule for the same reason as mini and telescope: it is
-- not needed before the first draw. It must also run AFTER lua/plugins/mini.lua,
-- because bufferline asks for `nvim-web-devicons` and this config has no such
-- plugin -- MiniIcons.mock_nvim_web_devicons() supplies it. vim.schedule
-- callbacks run in registration order and init.lua requires mini first, so the
-- mock is always in place by the time this runs.
vim.schedule(function()
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
        -- A space before the name, so the slant does not crowd it.
        return ' ' .. vim.fn.fnamemodify(buf.name, ':t')
      end,
    },
    highlights = {
      buffer_selected = {
        italic = false,
      },
    },
  }
end)

-- Hide the tabs without unloading the plugin.
vim.keymap.set('n', '<A-Tab>', function()
  vim.o.showtabline = vim.o.showtabline == 2 and 0 or 2
end, { desc = 'Toggle the buffer tabs' })
