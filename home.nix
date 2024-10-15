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

  home.bash.shellAliases = {
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
}
