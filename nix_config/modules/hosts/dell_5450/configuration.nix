{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos."nixosConfigurations/armin-work-laptop" = {
    networking.hostName = "armin-work-laptop"; # Define your hostname.
    system.stateVersion = "24.11";

    powerManagement.cpuFreqGovernor = "performance";

    home-manager.users.armin.imports = [ hm."nixosConfigurations/armin-work-laptop" ];
  };
}
