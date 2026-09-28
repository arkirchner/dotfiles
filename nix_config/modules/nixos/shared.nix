{ inputs, config, ... }:
{
  flake.modules.nixos.shared = {
    imports = [
      inputs.nvf.nixosModules.default

      config.flake.modules.nixos.boot
      config.flake.modules.nixos.nix
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.users
      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.bluetooth
      config.flake.modules.nixos.graphics
      config.flake.modules.nixos.fonts
      config.flake.modules.nixos.overlays
      config.flake.modules.nixos.packages
      config.flake.modules.nixos.postgresql
      config.flake.modules.nixos.podman
      config.flake.modules.nixos.nomad
      config.flake.modules.nixos.nvf
      config.flake.modules.nixos.qmk
      config.flake.modules.nixos.redis
      config.flake.modules.nixos.vpn
      config.flake.modules.nixos.libvirtd
      config.flake.modules.nixos.home-manager
    ];
  };
}
