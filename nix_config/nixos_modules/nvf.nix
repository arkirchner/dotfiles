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

        assistant.avante-nvim = {
          enable = true;
        };

        # Until https://github.com/yetone/avante.nvim/pull/2174 is in pkgs
        pluginOverrides = {
          avante-nvim = pkgs.fetchFromGitHub {
            owner = "yetone";
            repo = "avante.nvim";
            rev = "c7edd87820ea91a8c6f67ece5c47e27f720e5937";
            hash = "sha256-KP/Wg2pxpyBR3P9mjkLKcqsm5FlG9Cv+Fbe69V2dkXuBc4=";
          };
        };

        telescope = {
          enable = true;
          setupOpts.defaults.file_ignore_patterns = [
            "node_modules"
            "%.git/"
            "%.direnv"
            "dist/"
            "build/"
            "target/"
            "result/"
          ];
        };
      };
    };
  };
}
