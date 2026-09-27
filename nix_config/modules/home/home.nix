{ ... }:
{
  flake.modules.homeManager.home =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        tmux
        firefox
        chromedriver
        chromium
        kitty
        gnupg
        cmus
        pass
        kubectl
        kubernetes-helm
        snx-rs
        overmind
        gimp3
        libreoffice
        sqlite-interactive
        teams-for-linux
        dig
        btop
        pgadmin4-desktopmode
        glab
        opentofu
      ];
    };
}
