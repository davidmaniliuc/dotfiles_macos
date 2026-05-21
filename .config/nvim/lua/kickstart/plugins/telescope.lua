return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Define a function to set Telescope highlights
      local function set_telescope_highlights()
        local hl = vim.api.nvim_set_hl
        local bg = vim.api.nvim_get_hl_by_name('Normal', true).background
        local bg_alt = vim.api.nvim_get_hl_by_name('Visual', true).background
        local fg = vim.api.nvim_get_hl_by_name('Normal', true).foreground
        local green = vim.api.nvim_get_hl_by_name('String', true).foreground
        local red = vim.api.nvim_get_hl_by_name('Error', true).foreground

        hl(0, 'TelescopeBorder', { fg = bg_alt, bg = bg })
        hl(0, 'TelescopeNormal', { bg = bg })
        hl(0, 'TelescopePreviewBorder', { fg = bg, bg = bg })
        hl(0, 'TelescopePreviewNormal', { bg = bg })
        hl(0, 'TelescopePreviewTitle', { fg = bg, bg = green })
        hl(0, 'TelescopePromptBorder', { fg = bg_alt, bg = bg_alt })
        hl(0, 'TelescopePromptNormal', { fg = fg, bg = bg_alt })
        hl(0, 'TelescopePromptPrefix', { fg = red, bg = bg_alt })
        hl(0, 'TelescopePromptTitle', { fg = bg, bg = red })
        hl(0, 'TelescopeResultsBorder', { fg = bg, bg = bg })
        hl(0, 'TelescopeResultsNormal', { bg = bg })
        hl(0, 'TelescopeResultsTitle', { fg = bg, bg = bg })
      end

      -- Call the function to set the highlights
      set_telescope_highlights()

      require('telescope').setup {
        defaults = {
          layout_strategy = 'horizontal',
          layout_config = {
            prompt_position = 'top',
            preview_cutoff = 120,
            horizontal = {
              preview_width = 0.5,
            },
            vertical = {
              mirror = true,
            },
          },
          sorting_strategy = 'ascending',
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
      vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = '[] Find Files' })
      vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[F]ind Select Telescope' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind by [G]rep' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' })
      vim.keymap.set('n', '<leader>fs.', builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind existing [B]uffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>f/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[F]ind [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>fn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[F]find [N]eovim files' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
