local lspconfig = require("lspconfig")

lspconfig.nil_ls.setup {}
lspconfig.marksman.setup {}
lspconfig.yamlls.setup {}
lspconfig.bashls.setup {}
lspconfig.ruby_lsp.setup {
  -- cmd = { "bundle", "exec", "ruby-lsp" },
}

lspconfig.rubocop.setup {
  cmd = { "bundle", "exec", "rubocop", "--lsp" },
}

lspconfig.ltex.setup {
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
