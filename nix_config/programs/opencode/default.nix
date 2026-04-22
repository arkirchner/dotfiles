{ pkgs, ... }:
let
  railsMcpServer = pkgs.callPackage ../../packages/rails-mcp-server {};
in
{
  programs.opencode = {
    enable = true;
    settings = {
      mcp = {
        nixos = {
          type = "local";
          command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
        };
        context7 = {
          type = "local";
          command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
        };
        exa = {
          type = "remote";
          url = "https://mcp.exa.ai/mcp";
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
