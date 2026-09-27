{ ... }:
{
  flake.modules.nixos."nixosConfigurations/armin-pc".imports = [
    ./_hardware-configuration.nix
  ];
}
