-- options.lua
-- 基本オプション設定（dot_vimrcから移植）

local opt = vim.opt

-- Leader キー設定
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 表示
opt.number = true           -- 行番号
opt.cursorline = true       -- カーソル行ハイライト
opt.cursorcolumn = true     -- カーソル列ハイライト
opt.termguicolors = true    -- True Color
opt.background = 'dark'     -- ダークテーマ
opt.scrolloff = 5           -- スクロール時の余白
opt.signcolumn = 'yes'      -- サインカラム常時表示

-- インデント
opt.tabstop = 2             -- タブ幅
opt.shiftwidth = 2          -- インデント幅
opt.expandtab = true        -- タブをスペースに
opt.smartindent = true      -- スマートインデント

-- 検索
opt.hlsearch = true         -- 検索ハイライト
opt.incsearch = true        -- インクリメンタル検索
opt.ignorecase = true       -- 大文字小文字無視
opt.smartcase = true        -- 大文字含む場合は区別

-- 操作
opt.mouse = 'a'             -- マウス有効
opt.confirm = true          -- 保存確認
opt.clipboard = 'unnamedplus' -- システムクリップボード
opt.undofile = true         -- 永続的なundo
opt.updatetime = 250        -- 更新間隔短縮
opt.timeoutlen = 300        -- キーマップタイムアウト

-- 空白の可視化
opt.list = true
opt.listchars = { tab = '▸ ', trail = '·', nbsp = '␣' }

-- 分割
opt.splitright = true       -- 縦分割は右側
opt.splitbelow = true       -- 横分割は下側

-- 補完
opt.completeopt = 'menu,menuone,noselect'
