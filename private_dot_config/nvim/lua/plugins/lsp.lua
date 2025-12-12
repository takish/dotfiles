-- plugins/lsp.lua
-- LSP関連プラグイン

return {
  -- LSPクライアント設定
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'folke/neodev.nvim',
    },
  },

  -- LSPサーバー管理
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    config = function()
      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      })
    end,
  },

  -- mason + lspconfig 連携
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'ts_ls',       -- TypeScript/JavaScript
          'lua_ls',      -- Lua
          'bashls',      -- Bash/Shell
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP進捗表示
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    config = function()
      require('fidget').setup({
        notification = {
          window = {
            winblend = 0,
          },
        },
      })
    end,
  },

  -- Neovim Lua API補完
  {
    'folke/neodev.nvim',
    config = function()
      require('neodev').setup()
    end,
  },

  -- フォーマッター
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        mode = '',
        desc = 'フォーマット',
      },
    },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          typescriptreact = { 'prettier' },
          javascriptreact = { 'prettier' },
          json = { 'prettier' },
          markdown = { 'prettier' },
          lua = { 'stylua' },
          sh = { 'shfmt' },
          bash = { 'shfmt' },
          swift = { 'swiftformat' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- 診断リスト
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'Trouble', 'TroubleToggle' },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = '診断リスト' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = '現バッファ診断' },
    },
    config = function()
      require('trouble').setup()
    end,
  },
}
