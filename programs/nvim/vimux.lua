vim.api.nvim_set_keymap('n', '<Leader>vx', ':VimuxCloseRunner<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>vc', ':VimuxOpenRunner<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>sl', ":call VimuxRunCommand(getline('.'))<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>sl', ":<C-u>call VimuxRunCommand(join(getline(\"'<\", \"'>\"), \"\\n\"))<CR>", { noremap = true, silent = true })
