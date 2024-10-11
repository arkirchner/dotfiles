{ config, pkgs, ... }:

let
  tmuxConfig = builtins.readFile ./tmux.config;
in
{
  programs.tmux = {
    enable = true;

    extraConfig = tmuxConfig;

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
