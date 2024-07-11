return {
  "Wansmer/treesj",
  config = function()
    local keymap = vim.keymap
    local tsj = require("treesj")

    tsj.setup({
      use_default_keymaps = false,
    })
    keymap.set("n", "<leader>j", require("treesj").toggle, { desc = "Toggle TreesJ" })
  end,
}
