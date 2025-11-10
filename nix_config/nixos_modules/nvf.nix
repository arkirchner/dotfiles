{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.nvf = {
    enable = true;
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        options = {
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
        };

        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = true;
        };

        lsp = {
          enable = true;
          formatOnSave = false;

          lspconfig.enable = true;
          trouble.enable = true;
          lspSignature.enable = true;
          lightbulb.enable = true;
        };

        languages = {
          enableTreesitter = true;

          nix.enable = true;
          yaml.enable = true;
          # bash.enable = true;
          # css.enable = true;
          # helm.enable = true;
          # sql.enable = true;
          # ts.enable = true;
          # lua.enable = true;
          html.enable = true;
          # hcl.enable = true;
          # markdown.enable = true;
          tailwind.enable = true;
          # go.enable = true;
          # tex.enable = true;

          ruby = {
            enable = true;
            lsp = {
              package = pkgs.rubyPackages_3_4.ruby-lsp;
              server = "rubylsp";
            };
          };
        };

        autocomplete.nvim-cmp.enable = true;
        snippets.luasnip.enable = true;

        luaConfigPre = ''
          vim.g['test#strategy'] = 'vimux'
        '';

        keymaps = [
          # oil
          {
            key = "-";
            mode = "n";
            action = "<CMD>Oil<CR>";
            desc = "Open parent directory";
          }
          # vim-test
          {
            key = "<leader>s";
            mode = "n";
            silent = true;
            noremap = true;
            action = ":TestNearest<CR>";
          }
          {
            key = "<leader>t";
            mode = "n";
            silent = true;
            noremap = true;
            action = ":TestFile<CR>";
          }
          # vimux
          {
            key = "<leader>sl";
            mode = "n";
            silent = true;
            noremap = true;
            action = ":call VimuxRunCommand(getline('.'))<CR>";
          }
          {
            key = "<leader>sl";
            mode = "v";
            silent = true;
            noremap = true;
            action = ":<C-u>call VimuxRunCommand(join(getline(\"'<\", \"'>\"), \"\\n\"))<CR>";
          }
          # telescope
          {
            key = "<leader><leader>";
            mode = "n";
            action = "require(\"telescope.builtin\").oldfiles";
            lua = true;
          }
        ];

        extraPlugins = with pkgs.vimPlugins; {
          vim-test = {
            package = vim-test;
          };

          vimux = {
            package = vimux;
          };
        };

        # TODO: Try this!
        # assistant.avante-nvim = {
        #   enable = true;
        #   setupOpts = {
        #     provider = "copilot";
        #     copilot = {
        #       model = "claude-3.5-sonnet";
        #       endpoint = "https://api.githubcopilot.com";
        #       allow_insecure = false;
        #       timeout = 10 * 60 * 1000;
        #       temperature = 0;
        #       max_completion_tokens = 1000000;
        #       reasoning_effort = "high";
        #     };
        #   };
        # };

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
            "log/"
            "coverage/"
            "%.bundle/"
            "public/packs-test"
            "public/packs"
            "public/assets/webpack"
          ];
        };

        utility = {
          oil-nvim.enable = true;
        };
      };
    };
  };
}
