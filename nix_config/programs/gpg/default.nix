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
      package = pkgs.pinentry-qt;
    };
  };
}
