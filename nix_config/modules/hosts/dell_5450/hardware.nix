{ ... }:
{
  flake.modules.nixos."nixosConfigurations/armin-work-laptop".imports = [
    ./_hardware-configuration.nix
  ];
}
