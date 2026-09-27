{ config, ... }:
{
  flake.modules.homeManager.programs = {
    imports = with config.flake.modules.homeManager; [
      fish
      tmux
      kitty
      vscode
      gpg
      git
      opencode
      hermes-agent
    ];
  };
}
