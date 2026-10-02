{ ... }:
{
  flake.modules.homeManager.home =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        firefox
        chromedriver
        chromium
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
        glab
        opentofu
        # An app's .envrc reads the nixpkgs revision out of flake.lock with jq,
        # and direnv evaluates that before any dev shell is on the PATH.
        jq
        # Per-project dev environments. An app repo holds no devenv files at
        # all: its .envrc points `use devenv --from` at ../../devenv/<app>.
        devenv
      ];
    };
}
