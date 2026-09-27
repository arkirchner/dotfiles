{ config, inputs, ... }:
{
  flake.nixosConfigurations.armin-pc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      config.flake.modules.nixos.shared
      config.flake.modules.nixos."nixosConfigurations/armin-pc"
    ];
  };
}
