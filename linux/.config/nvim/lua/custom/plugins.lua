local cmp = require "cmp"

local plugins = {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "zbirenbaum/copilot.lua",
    lazy = false,
    config = function()
      require("copilot").setup({})
    end,
  },
  {
    "christoomey/vim-tmux-runner",
    lazy = false,
    init = function ()
     vim.g.VtrUseVtrMaps = 1
    end
  },
}

return plugins
