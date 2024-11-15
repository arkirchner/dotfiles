local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.nil_ls.setup {
  capabilities = capabilities,
}
lspconfig.marksman.setup {
  capabilities = capabilities,
}
lspconfig.yamlls.setup {
  capabilities = capabilities,
}
lspconfig.bashls.setup {
  capabilities = capabilities,
}
lspconfig.ruby_lsp.setup {
  capabilities = capabilities,
  -- cmd = { "bundle", "exec", "ruby-lsp" },
}

lspconfig.tsserver.setup {
  capabilities = capabilities,
}

-- Disabled because this should be handled by the ruby_lsp bit it is not ...
-- lspconfig.rubocop.setup {
--   capabilities = capabilities,
--   cmd = { "bundle", "exec", "rubocop", "--lsp" },
-- }

lspconfig.ltex.setup {
  capabilities = capabilities,
  settings = {
    ltex = {
      language = "en-US",
      additionalRules = {
        enablePickyRules = true,
        motherTongue = "de-DE"
      }
    }
  },
  filetypes = {
    "bib",
    "gitcommit",
    "markdown",
    "org",
    "plaintex",
    "rst",
    "rnoweb",
    "tex",
    "pandoc",
    "quarto",
    "rmd",
    "ruby"
  }
  -- root_dir = util.root_dir(".git"),
}

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, opts)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
