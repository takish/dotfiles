-- plugins/treesitter.lua
-- Treesitter プラグイン定義

return {
  {
    'nvim-treesitter/nvim-treesitter',
    tag = 'v0.9.2',  -- configs API をサポートする最後の安定版
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        -- インストールする言語パーサー
        ensure_installed = {
          -- 主要言語
          'typescript',
          'tsx',
          'javascript',
          'lua',
          'bash',
          -- マークアップ・設定
          'html',
          'css',
          'json',
          'yaml',
          'toml',
          'markdown',
          'markdown_inline',
          -- その他
          'vim',
          'vimdoc',
          'query',
          'regex',
          'gitignore',
        },

        -- 自動インストール
        auto_install = true,

        -- シンタックスハイライト
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        -- インデント
        indent = {
          enable = true,
        },

        -- テキストオブジェクト
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']f'] = '@function.outer',
              [']c'] = '@class.outer',
            },
            goto_previous_start = {
              ['[f'] = '@function.outer',
              ['[c'] = '@class.outer',
            },
          },
        },
      })
    end,
  },

  -- HTML/JSXタグ自動閉じ
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
}
