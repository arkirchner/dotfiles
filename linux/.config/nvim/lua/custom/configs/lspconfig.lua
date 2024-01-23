local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
-- local util = require "lspconfig/util"

lspconfig.ltex.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  -- root_dir = util.root_dir(".git"),
}

lspconfig.ruby_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

lspconfig.rubocop.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
