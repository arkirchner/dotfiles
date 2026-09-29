{ ... }:
{
  # TEMPORARY: provides the Hyprland Wayland session as a fallback while the
  # niri + Noctalia setup is validated. Remove this module in Phase 5 of the
  # niri migration (see TODO.md).
  flake.modules.nixos.hyprland = {
    programs.hyprland.enable = true;
  };
}
