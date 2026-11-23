{ inputs, ... }:
{
  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    let
      railsMcpServer = pkgs.callPackage ../../../packages/rails-mcp-server { };
      skills = "${inputs.rails-consultant}/skills";
    in
    {
      programs.opencode = {
        enable = true;
        settings = {
          lsp = true;
          model = "hpi/HPI-Intern-Qwen38-27B#medium";
          provider = {
            hpi = {
              npm = "@ai-sdk/openai-compatible";
              name = "HPI";
              options = {
                baseURL = "https://101010.hpi.de/api/v1";
              };
              models = {
                "HPI-Intern-Qwen3.6-35B-A3B" = {
                  name = "HPI Qwen 3.6 35B";
                  attachment = false;
                  reasoning = true;
                  tool_call = true;
                  limit = {
                    context = 229376;
                    output = 32768;
                  };
                };
                "HPI-Intern-Qwen38-27B" = {
                  name = "HPI Qwen 3.8 27B";
                  attachment = true;
                  reasoning = true;
                  tool_call = true;
                  interleaved = "reasoning_content";
                  limit = {
                    context = 434464;
                    output = 65536;
                  };
                  options = {
                    chat_template_kwargs = {
                      enable_thinking = true;
                    };
                  };
                  variants = {
                    low = {
                      reasoning_effort = "low";
                    };
                    medium = {
                      reasoning_effort = "medium";
                    };
                    xhigh = {
                      reasoning_effort = "xhigh";
                    };
                    off = {
                      chat_template_kwargs = {
                        enable_thinking = false;
                      };
                    };
                  };
                };
              };
            };
          };
          permission = {
            external_directory."/nix/store/**" = "allow";
            edit."/nix/store/**" = "deny";
          };
          mcp = {
            nixos = {
              type = "local";
              command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
            };
            context7 = {
              type = "local";
              command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
            };
            playwright = {
              type = "local";
              command = [ "${pkgs.playwright-mcp}/bin/playwright-mcp" ];
            };
            rails = {
              type = "local";
              command = [ "${railsMcpServer}/bin/rails-mcp-server" ];
              # Rails shells opt back in through OPENCODE_CONFIG; everywhere
              # else this server is dead weight.
              enabled = false;
            };
          };
        };
      };

      home.file.".config/opencode/agents/".source = ./agents;
      home.file.".config/opencode/skills/".source = skills;
      home.file.".config/opencode/AGENTS.md".source = ./AGENTS.md;
    };
}
