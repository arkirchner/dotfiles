{ config, pkgs, ... }:
{
  programs.nvf = {
    enable = true;
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = true;
        };

        lsp = {
          enable = true;

          lspconfig.enable = true;
        };

        languages = {
          ruby = {
            enable = true;
            treesitter.enable = true;
            lsp = {
              enable = true;
              server = "rubylsp";
            };
          };
        };
      };
    };
  };
}
