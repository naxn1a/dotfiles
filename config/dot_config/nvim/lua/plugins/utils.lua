return {
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    dependencies = {
    },
    config = function()
      local autopairs = require("nvim-autopairs")

      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
          java = false,
        },
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")

      local cmp = require("cmp")

      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  -- Comment
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      local comment = require("Comment")

      local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

      comment.setup({
        pre_hook = ts_context_commentstring.create_pre_hook(),
      })
    end,
  },
  -- Wildfire
  {
    "gcmt/wildfire.vim",
  },
  -- Indent Scope
  {
    "echasnovski/mini.indentscope",
    config = function()
      require("mini.indentscope").setup()
    end,
  }
}
