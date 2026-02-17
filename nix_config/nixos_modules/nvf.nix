{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Define a Ruby environment with the ruby-lsp gem
  # pkgs.ruby points to the latest stable Ruby in nixos-unstable
  rubyWithLsp = pkgs.ruby_3_4.withPackages (rbPkgs: with rbPkgs; [
    ruby-lsp
  ]);
in
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

          # New LSP configuration for Ruby LSP
          servers.ruby_lsp.cmd = lib.mkForce [ "${rubyWithLsp}/bin/ruby-lsp" ];
        };

        languages = {
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
          # tailwind.enable = true;
          # go.enable = true;
          tex.enable = true;

          ruby = {
            enable = true;
            lsp = {
              servers = ["ruby_lsp"];
            };
          };
        };

        autocomplete.nvim-cmp = {
          enable = true;
          sources = lib.mkForce {
            nvim_lsp = null;
            path = null;
            buffer = null;
          };
          setupOpts = {
            experimental.ghost_text = true;
            matching = {
              disallow_fuzzy_matching = false;
              disallow_fullfuzzy_matching = false;
              disallow_partial_fuzzy_matching = false;
              disallow_prefix_unmatching = false;
            };
          };
        };
        snippets.luasnip.enable = false;

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
            "app/assets/builds/"
          ];
        };

        utility = {
          oil-nvim.enable = true;
        };
      };
    };
  };
}
