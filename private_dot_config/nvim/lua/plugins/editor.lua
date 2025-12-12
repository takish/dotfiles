-- plugins/editor.lua
-- エディタ拡張（QoL）

return {
  -- 括弧自動補完
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true,
        ts_config = {
          lua = { 'string' },
          javascript = { 'template_string' },
        },
      })
      -- cmpとの連携
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  -- 囲み文字操作
  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup()
    end,
  },

  -- コメント操作
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('Comment').setup({
        toggler = {
          line = 'gcc',
          block = 'gbc',
        },
        opleader = {
          line = 'gc',
          block = 'gb',
        },
      })
    end,
  },

  -- キーバインドヘルプ
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup({
        plugins = {
          spelling = {
            enabled = true,
          },
        },
        win = {
          border = 'rounded',
        },
      })

      -- キーグループ登録
      wk.add({
        { '<leader>f', group = 'Find (Telescope)' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Git hunks' },
        { '<leader>x', group = 'Diagnostics' },
        { '<leader>c', group = 'Code' },
        { '<leader>b', group = 'Buffer' },
        { '<leader>t', group = 'Toggle' },
      })
    end,
  },

  -- TODO/FIXME ハイライト
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { ']t', function() require('todo-comments').jump_next() end, desc = '次のTODO' },
      { '[t', function() require('todo-comments').jump_prev() end, desc = '前のTODO' },
      { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'TODO検索' },
    },
    config = function()
      require('todo-comments').setup()
    end,
  },

  -- カラーコードプレビュー
  {
    'NvChad/nvim-colorizer.lua',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('colorizer').setup({
        filetypes = { '*' },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          RRGGBBAA = true,
          css = true,
          css_fn = true,
          mode = 'background',
        },
      })
    end,
  },

  -- 起動画面
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      dashboard.section.header.val = {
        '',
        '  ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
        '  ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
        '  ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
        '  ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
        '  ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
        '  ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
        '',
      }

      dashboard.section.buttons.val = {
        dashboard.button('f', '  Find file', ':Telescope find_files <CR>'),
        dashboard.button('r', '  Recent files', ':Telescope oldfiles <CR>'),
        dashboard.button('g', '  Find text', ':Telescope live_grep <CR>'),
        dashboard.button('e', '  File Explorer', ':Neotree toggle <CR>'),
        dashboard.button('c', '  Config', ':e ~/.config/nvim/init.lua <CR>'),
        dashboard.button('l', '󰒲  Lazy', ':Lazy <CR>'),
        dashboard.button('q', '  Quit', ':qa <CR>'),
      }

      alpha.setup(dashboard.config)
    end,
  },
}
