{ config, pkgs, ... }:
let
  tatConfig = "${builtins.readFile ./stay_always_in_tmux}";
in
{
  home.shellAliases = {
    gs = "git status ";
    ga = "git add ";
    gb = "git branch --sort=-committerdate ";
    gc = "git commit";
    gd = "git diff";
    go = "git checkout ";
    gk = "gitk --all&";
    gx = "gitx --all";
    hpi-vpn = "sudo snx-rs -o vpn -s vpn.hpi.de";
  };
  home.packages = with pkgs; [
    fastfetch
    gemini-cli
  ];

  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
    };

    bash = {
      enable = true;

      bashrcExtra = ''
        ${tatConfig}
        fastfetch
      '';
    };
  };
}
