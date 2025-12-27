-- 基本オプションの設定
require('options')

-- キーマップの設定
require('keymaps')

-- プラグインの設定
require('plugins')

-- 各種セットアップ（例：Tree-sitter, LSPなど）
-- require('setup.treesitter')  -- プラグイン定義内で設定するためコメントアウト
require('setup.lspconfig')

