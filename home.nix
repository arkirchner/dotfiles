{ config, pkgs, lib, ... }:
{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.alacritty
    pkgs.neovim
    pkgs.tmux
  ];

  imports = (import ./programs);
}
