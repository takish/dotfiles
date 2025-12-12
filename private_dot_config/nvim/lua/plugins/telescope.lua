-- plugins/telescope.lua
-- ファジーファインダー

return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'ファイル検索' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Grep検索' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'バッファ一覧' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'ヘルプ検索' },
      { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = '最近のファイル' },
      { '<leader>fc', '<cmd>Telescope commands<cr>', desc = 'コマンド一覧' },
      { '<leader>fk', '<cmd>Telescope keymaps<cr>', desc = 'キーマップ一覧' },
      { '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'シンボル検索' },
      { '<leader>fd', '<cmd>Telescope diagnostics<cr>', desc = '診断一覧' },
      { '<leader>gc', '<cmd>Telescope git_commits<cr>', desc = 'Gitコミット履歴' },
      { '<leader>gs', '<cmd>Telescope git_status<cr>', desc = 'Git status' },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<Esc>'] = actions.close,
            },
          },
          file_ignore_patterns = {
            'node_modules',
            '.git/',
            '%.lock',
          },
          path_display = { 'truncate' },
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })

      -- fzf拡張読み込み
      telescope.load_extension('fzf')
    end,
  },
}
