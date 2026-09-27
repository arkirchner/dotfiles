{ ... }:
{
  flake.modules.nixos."nixosConfigurations/armin-laptop".imports = [
    ./_hardware-configuration.nix
  ];
}
