{ ... }:
{
  flake.modules.nixos.graphics = {
    # Hardware accelerated graphics.
    hardware.graphics.enable = true;
  };
}
