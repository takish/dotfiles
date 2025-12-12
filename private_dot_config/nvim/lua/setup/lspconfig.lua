-- setup/lspconfig.lua
-- LSPサーバー設定

local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- LSP接続時のキーマップ設定
local on_attach = function(client, bufnr)
  local keymap = function(mode, keys, func, desc)
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
  end

  -- 定義・参照
  keymap('n', 'gd', vim.lsp.buf.definition, '定義へジャンプ')
  keymap('n', 'gD', vim.lsp.buf.declaration, '宣言へジャンプ')
  keymap('n', 'gr', vim.lsp.buf.references, '参照一覧')
  keymap('n', 'gi', vim.lsp.buf.implementation, '実装へジャンプ')
  keymap('n', 'gt', vim.lsp.buf.type_definition, '型定義へジャンプ')

  -- 情報表示
  keymap('n', 'K', vim.lsp.buf.hover, 'ホバー情報')
  keymap('n', '<C-k>', vim.lsp.buf.signature_help, 'シグネチャヘルプ')

  -- アクション
  keymap('n', '<leader>rn', vim.lsp.buf.rename, 'リネーム')
  keymap({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'コードアクション')

  -- 診断
  keymap('n', '[d', vim.diagnostic.goto_prev, '前の診断')
  keymap('n', ']d', vim.diagnostic.goto_next, '次の診断')
  keymap('n', '<leader>d', vim.diagnostic.open_float, '診断詳細')
end

-- 補完機能の追加
local capabilities = cmp_nvim_lsp.default_capabilities()

-- TypeScript/JavaScript
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Lua（Neovim設定用）
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Bash/Shell
lspconfig.bashls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Swift（Xcode付属のsourcekit-lspを使用）
lspconfig.sourcekit.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { '/usr/bin/sourcekit-lsp' },
  filetypes = { 'swift', 'objective-c', 'objective-cpp' },
})

-- 診断の表示設定
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

-- 診断アイコン
local signs = { Error = ' ', Warn = ' ', Hint = '󰌵 ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end
