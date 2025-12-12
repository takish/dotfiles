-- plugins/neo-tree.lua
-- ファイルエクスプローラー

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'ファイラー' },
      { '<leader>o', '<cmd>Neotree focus<cr>', desc = 'ファイラーにフォーカス' },
    },
    config = function()
      require('neo-tree').setup({
        close_if_last_window = true,
        popup_border_style = 'rounded',
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          indent = {
            with_expanders = true,
          },
          icon = {
            folder_closed = '',
            folder_open = '',
            folder_empty = '',
          },
          git_status = {
            symbols = {
              added = '✚',
              modified = '',
              deleted = '✖',
              renamed = '󰁕',
              untracked = '',
              ignored = '',
              unstaged = '󰄱',
              staged = '',
              conflict = '',
            },
          },
        },
        window = {
          position = 'left',
          width = 35,
          mappings = {
            ['<space>'] = 'none',
            ['l'] = 'open',
            ['h'] = 'close_node',
            ['<cr>'] = 'open',
            ['s'] = 'open_split',
            ['v'] = 'open_vsplit',
          },
        },
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              'node_modules',
              '.git',
            },
          },
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
        git_status = {
          window = {
            position = 'float',
          },
        },
      })
    end,
  },
}
