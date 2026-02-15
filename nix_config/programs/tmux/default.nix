{ config, pkgs, ... }:

let
  tat = import ./tat.nix { inherit pkgs; };
in
{
  home.packages = [
    tat
    pkgs.fzf
  ];

  programs.tmux = {
    enable = true;

    terminal = "screen-256color";

    extraConfig = ''
      ${builtins.readFile ./tmux.config}
    '';

    plugins = with pkgs; [
      { plugin = tmuxPlugins.sensible; }
      { plugin = tmuxPlugins.yank; }
      { plugin = tmuxPlugins.vim-tmux-navigator; }

      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = "set -g @catppuccin_flavour 'mocha'";
      }
    ];
  };
}
