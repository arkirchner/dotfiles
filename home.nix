{ config, pkgs, lib, ... }:
{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    (writeShellScriptBin "tat" (builtins.readFile ./bin/tat))
    pkgs.kitty
    pkgs.neovim
    pkgs.tmux
  ];

  imports = (import ./programs);
}
