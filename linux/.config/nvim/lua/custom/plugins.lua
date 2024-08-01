local cmp = require "cmp"

local plugins = {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "ltex-ls",
        "rubocop",
        "ruby-lsp",
      },
    },
  },
  {
    "windwp/nvim-autopairs",
    enable = false,
  },
  {
    "neovim/nvim-lspconfig",
    config = function ()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "vim-test/vim-test",
    lazy = false,
    init = function()
      vim.g['test#strategy'] = 'vtr'
      vim.api.nvim_set_keymap('n', '<leader>s', ':TestNearest<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>t', ':TestFile<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>a', ':TestSuite<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>l', ':TestLast<CR>', { noremap = true, silent = true })
    end
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "zbirenbaum/copilot.lua",
    lazy = false,
    config = function()
      require("copilot").setup({
        suggestion = {
          auto_trigger = true
        }
      })
    end,
  },
  {
    "christoomey/vim-tmux-runner",
    lazy = false,
    init = function ()
      vim.g.VtrUseVtrMaps = 1
    end
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({})
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim"
    }
  }
}

return plugins
