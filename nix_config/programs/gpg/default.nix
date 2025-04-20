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
    pinentryPackage = if pkgs.stdenv.isDarwin
                      then pkgs.pinentry_mac
                      else pkgs.wayprompt;
  };
}
