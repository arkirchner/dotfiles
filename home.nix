{ config, pkgs, lib, ... }:
{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";

    gs = "git status ";
    ga = "git add ";
    gb = "git branch ";
    gc = "git commit";
    gd = "git diff";
    go = "git checkout ";
    gk = "gitk --all&";
    gx = "gitx --all";
  };

  imports = (import ./programs);
}
