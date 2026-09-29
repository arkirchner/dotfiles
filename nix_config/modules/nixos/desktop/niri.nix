{ ... }:
{
  flake.modules.nixos.niri = {
    # Adds the niri Wayland session, portal defaults (gnome + gtk) and
    # xdg-desktop-portal-gnome. User-level compositor settings live in
    # modules/home/desktop/niri/default.nix.
    programs.niri.enable = true;
  };
}
