{ ... }:
{
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;
    networking.extraHosts = ''
      10.0.0.20 test.local
      10.0.0.21 longhorn.test.local
    '';
  };
}
