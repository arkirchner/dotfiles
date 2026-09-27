{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos."nixosConfigurations/armin-pc" = {
    networking.hostName = "armin-pc"; # Define your hostname.
    system.stateVersion = "24.11";

    home-manager.users.armin.imports = [ hm.armin ];
  };
}
