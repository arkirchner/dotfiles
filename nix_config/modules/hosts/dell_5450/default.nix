{ config, inputs, ... }:
{
  flake.nixosConfigurations.armin-work-laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      config.flake.modules.nixos.shared
      config.flake.modules.nixos."nixosConfigurations/armin-work-laptop"
    ];
  };
}
