-- git-blame.nvim: 各行の git blame を表示
return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  opts = {
    enabled = true,
    message_template = " <author> | <date> | <summary>",
    date_format = "%Y-%m-%d",
    virtual_text_column = 80, -- blame を表示する最小カラム位置
    delay = 500, -- 表示までの遅延 (ms)
  },
  keys = {
    { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
    { "<leader>gB", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open Commit URL" },
    { "<leader>gc", "<cmd>GitBlameCopySHA<cr>", desc = "Copy Commit SHA" },
  },
}
