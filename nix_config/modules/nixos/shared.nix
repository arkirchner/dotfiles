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
      config.flake.modules.nixos.niri
      config.flake.modules.nixos.noctalia
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.bluetooth
      config.flake.modules.nixos.graphics
      config.flake.modules.nixos.fonts

      config.flake.modules.nixos.packages
      config.flake.modules.nixos.podman
      config.flake.modules.nixos.nvf
      config.flake.modules.nixos.qmk
      config.flake.modules.nixos.vpn
      config.flake.modules.nixos.libvirtd
      config.flake.modules.nixos.home-manager
    ];

    # Every host runs the same Home Manager config; hosts add their own modules
    # (e.g. per-machine niri outputs) on top of this list.
    home-manager.users.armin.imports = [ config.flake.modules.homeManager.armin ];
  };
}
