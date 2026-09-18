{ pkgs, ... }:
let
  railsMcpServer = pkgs.callPackage ../../packages/rails-mcp-server {};
in
{
  programs.opencode = {
    enable = true;
    settings = {
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
              limit = {
                context = 434464;
                output = 65536;
              };
            };
          };
        };
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
        rails = {
          type = "local";
          command = [ "${railsMcpServer}/bin/rails-mcp-server" ];
        };
      };
    };
  };

  home.file.".config/opencode/agents/".source = ./agents;
  home.file.".config/opencode/AGENTS.md".source = ./AGENTS.md;
}
