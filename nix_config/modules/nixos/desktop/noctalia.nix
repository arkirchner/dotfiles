{ ... }:
{
  flake.modules.nixos.noctalia = {
    # Noctalia desktop shell. Not started via a systemd user service during
    # the Hyprland parallel phase (the unit targets graphical-session.target,
    # which Hyprland also reaches); niri spawns it via spawn-at-startup.
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    # Replaces tuigreet; lists the available Wayland sessions (niri and
    # Hyprland during the parallel phase).
    services.displayManager.noctalia-greeter.enable = true;
  };
}
