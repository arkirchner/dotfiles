{ config, pkgs, lib, ... }:
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
          formatOnSave = true;

          lspconfig.enable = true;
          trouble.enable = true;
          lspSignature.enable = true;
          lightbulb.enable = true;
        };

        languages = {
          enableTreesitter = true;

          # nix.enable = true;
          # yaml.enable = true;
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

          ruby = {
            enable = true;
            lsp = {
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
        ];

        extraPlugins = with pkgs.vimPlugins; {
          vim-test = {
            package = vim-test;
          };
          
          vimux = {
            package = vimux;
          };
        };

        assistant.codecompanion-nvim = {
          enable = true;
          setupOpts = {
            adapters = lib.generators.mkLuaInline ''
              {
                anthropic = function()
                  return require("codecompanion.adapters").extend("anthropic", {
                    env = {
                      api_key = (function()
                        local handle = io.popen("pass show api/anthropic")
                        if handle then
                          local result = handle:read("*a")
                          handle:close()
                          return vim.trim(result)
                        else
                          vim.notify("Failed to read Anthropic API key from pass", vim.log.levels.ERROR)
                          return nil
                        end
                      end)(),
                    },
                  })
                end,
               }
            '';

            strategies = {
              chat = {
                adapter = "anthropic";
              };
              inline = {
                adapter = "anthropic";
              };
              cmd = {
                adapter = "anthropic";
              };
            };
            display = {
              chat = {
                auto_scroll = true;
                show_settings = true;
              };
              action_palette.provider = "telescope";
            };
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
          ];
        };

        utility = {
          oil-nvim.enable = true;
        };
      };
    };
  };
}
