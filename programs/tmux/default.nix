{ config, pkgs, ... }:

let
  tat = import ./tat.nix { inherit pkgs; };
in
{
  home.packages = [
    tat
  ];

  programs.tmux = {
    enable = true;

    shell = "${pkgs.bashInteractive}/bin/bash";
    terminal = "screen-256color";

    extraConfig = ''
      ${builtins.readFile ./tmux.config}

      # On the Mac the Tmux planes are always executed with the system bash binary.
      ${ if pkgs.stdenv.isDarwin then "set-option -g default-command \"exec ${pkgs.bashInteractive}/bin/bash\"" else "" }
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
