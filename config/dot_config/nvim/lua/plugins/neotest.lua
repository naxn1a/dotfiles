return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter"
  },
  keys = {
    { "<leader>u",  "",                                                                                 desc = "+test" },
    { "<leader>ut", function() require("neotest").run.run(vim.fn.expand("%")) end,                      desc = "Run File" },
    { "<leader>uT", function() require("neotest").run.run(vim.uv.cwd()) end,                            desc = "Run All Test Files" },
    { "<leader>ur", function() require("neotest").run.run() end,                                        desc = "Run Nearest" },
    { "<leader>ul", function() require("neotest").run.run_last() end,                                   desc = "Run Last" },
    { "<leader>us", function() require("neotest").summary.toggle() end,                                 desc = "Toggle Summary" },
    { "<leader>uo", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
    { "<leader>uO", function() require("neotest").output_panel.toggle() end,                            desc = "Toggle Output Panel" },
    { "<leader>uS", function() require("neotest").run.stop() end,                                       desc = "Stop" },
    { "<leader>uw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end,                 desc = "Toggle Watch" },
  },
}
