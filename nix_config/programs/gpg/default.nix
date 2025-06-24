{ config, pkgs, ... }:
{
  programs.gpg = {
    scdaemonSettings.disbale-ccid = true;

    publicKeys = [
      {
        source = ./armin.gpg;
        trust = 5;
      }
    ];
  };

  services.gpg-agent = {
    enable = true;

    enableSshSupport = true;
    pinentry = {
      package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.wayprompt;
    };
  };
}
