-- keymaps.lua
-- キーマップ設定

local keymap = vim.keymap.set

-- jj で Escape
keymap('i', 'jj', '<Esc>', { desc = 'Escapeに戻る' })

-- 行頭・行末へ
keymap('n', 'H', '^', { desc = '行頭へ' })
keymap('n', 'L', '$', { desc = '行末へ' })

-- バッファ移動
keymap('n', '<Tab>', ':bnext<CR>', { desc = '次のバッファ', silent = true })
keymap('n', '<S-Tab>', ':bprevious<CR>', { desc = '前のバッファ', silent = true })

-- Esc 2回で検索ハイライト解除
keymap('n', '<Esc><Esc>', ':nohlsearch<CR>', { desc = '検索ハイライト解除', silent = true })

-- ウィンドウ移動 (Ctrl + hjkl)
keymap('n', '<C-h>', '<C-w>h', { desc = '左ウィンドウへ' })
keymap('n', '<C-j>', '<C-w>j', { desc = '下ウィンドウへ' })
keymap('n', '<C-k>', '<C-w>k', { desc = '上ウィンドウへ' })
keymap('n', '<C-l>', '<C-w>l', { desc = '右ウィンドウへ' })

-- 行移動（ビジュアルモードで選択行を上下に移動）
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = '選択行を下に移動', silent = true })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = '選択行を上に移動', silent = true })

-- 保存
keymap('n', '<leader>w', ':w<CR>', { desc = '保存', silent = true })
keymap('n', '<leader>q', ':q<CR>', { desc = '閉じる', silent = true })

-- バッファ削除
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'バッファ削除', silent = true })

-- ヤンク後にカーソル位置を保持
keymap('v', 'y', 'ygv<Esc>', { desc = 'ヤンク（位置保持）' })

-- 選択してペースト後もレジスタを保持
keymap('x', 'p', '"_dP', { desc = 'ペースト（レジスタ保持）' })

-- 行番号トグル（コピー用）
keymap('n', '<leader>n', ':set number!<CR>', { desc = '行番号トグル', silent = true })
