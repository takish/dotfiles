-- plugins.lua
-- lazy.nvim ブートストラップとプラグイン読み込み

-- lazy.nvim 自動インストール
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン読み込み
require('lazy').setup({
  -- プラグインspec（各ファイルから読み込み）
  { import = 'plugins.ui' },
  { import = 'plugins.treesitter' },
  { import = 'plugins.lsp' },
  { import = 'plugins.completion' },
  { import = 'plugins.telescope' },
  { import = 'plugins.neo-tree' },
  { import = 'plugins.git' },
  { import = 'plugins.editor' },
}, {
  -- lazy.nvim 設定
  defaults = {
    lazy = false,
  },
  install = {
    colorscheme = { 'tokyonight' },
  },
  checker = {
    enabled = true,        -- 自動更新チェック
    notify = false,        -- 通知は控えめに
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
