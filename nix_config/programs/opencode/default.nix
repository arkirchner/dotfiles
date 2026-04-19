{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
  };

  home.file.".config/opencode/agents/".source = ./agents;
}
