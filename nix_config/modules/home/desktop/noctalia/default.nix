{ ... }:
{
  flake.modules.homeManager.noctalia =
    { ... }:
    {
      programs.noctalia = {
        enable = true;

        # systemd intentionally left off during the Hyprland parallel phase:
        # the unit targets graphical-session.target, which Hyprland also
        # reaches, so Noctalia would fight Waybar/Mako. niri starts it via
        # spawn-at-startup instead.

        settings = {
          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Catppuccin";
          };

          wallpaper = {
            enabled = true;
            directory = "${../../../../wallpapers}";
            default.path = "${../../../../wallpapers/night-mountain.jpg}";
          };

          # Blurred wallpaper backdrop for niri's overview (see the layer-rule
          # in modules/home/desktop/niri).
          backdrop.enabled = true;

          # Bar mirroring the old Waybar set: workspaces, window title, then
          # network/volume/bluetooth/battery/clock.
          bar.default = {
            position = "top";
            start = [ "launcher" "workspaces" ];
            center = [ "active_window" ];
            end = [
              "network"
              "volume"
              "bluetooth"
              "battery"
              "clock"
            ];
          };

          lockscreen = {
            enabled = true;
            blurred_desktop = true;
            lock_before_suspend = true;
          };

          # Lock after 10 minutes idle.
          idle.behavior.lock = {
            enabled = true;
            timeout = 600.0;
          };
        };
      };
    };
}
