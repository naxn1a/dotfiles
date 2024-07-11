return {
  "nvimdev/dashboard-nvim",
  config = function()
    local api = vim.api
    local keymap = vim.keymap
    local dashboard = require("dashboard")

    local conf = {}
    conf.header = {
      "                                                       ",
      "                                                       ",
      "                                                       ",
      " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
      " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
      " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
      " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
      " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
      " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
      "                                                       ",
      "                                                       ",
      "                                                       ",
      "                                                       ",
    }

    conf.center = {
      {
        icon = "  ",
        desc = "New file                                ",
        key = " e ",
      },
      {
        icon = "󰈞  ",
        desc = "Find  File                              ",
        key = " <Leader> f f ",
      },
      {
        icon = "󰗼  ",
        desc = "Quit Nvim                               ",
        key = " q ",
      },
    }

    dashboard.setup({
      theme = 'doom',
      shortcut_type = 'number',
      config = conf
    })

    api.nvim_create_autocmd("FileType", {
      pattern = "dashboard",
      group = api.nvim_create_augroup("dashboard_enter", { clear = true }),
      callback = function()
        keymap.set("n", "q", ":qa<CR>", { buffer = true, silent = true })
        keymap.set("n", "e", ":enew<CR>", { buffer = true, silent = true })
      end
    })
  end,
}
