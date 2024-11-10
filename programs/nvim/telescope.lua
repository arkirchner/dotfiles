local telescope = require("telescope")

telescope.setup {
  pickers = {
    find_files = {
      hidden = true,
      theme = "ivy",
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
  },
}

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})

telescope.load_extension("ui-select")
