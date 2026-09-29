{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos."nixosConfigurations/armin-laptop" = {
    networking.hostName = "armin-laptop"; # Define your hostname.
    system.stateVersion = "24.11";

    # Fix netwerk issues caused by bluetooth on Ideapad 720s
    boot.extraModprobeConfig = "options rtw88_core disable_lps_deep=Y";

    # Disable buggy tpm2 driver (might be fixed in newer kernel)
    systemd.tpm2.enable = false;
    boot.initrd.systemd.tpm2.enable = false;

    home-manager.users.armin.imports = [ hm."nixosConfigurations/armin-laptop" ];
  };
}
