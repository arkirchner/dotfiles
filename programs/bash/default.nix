{ config, pkgs, ... }:
let
  tatConfig = "${builtins.readFile ../../linux/.bashrc.d/tmux}";
in
{
  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  
    gs = "git status ";
    ga = "git add ";
    gb = "git branch --sort=-committerdate ";
    gc = "git commit";
    gd = "git diff";
    go = "git checkout ";
    gk = "gitk --all&";
    gx = "gitx --all";
  };

  programs.bash = {
    enable = true;

    bashrcExtra = ''
      ${tatConfig}
    '';
  };
}
