{ ... }:
{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia = {
        enable = true;

        # Started by niri's spawn-at-startup, so no systemd service here.
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

            # A random wallpaper from the same directory at every shell start,
            # then a new one every hour. The picks cycle through
            # `directory`, not `default.path`.
            automation = {
              enabled = true;
              interval_seconds = 3600;
              order = "random";
            };
          };

          # Blurred wallpaper backdrop for niri's overview (see the layer-rule
          # in modules/home/desktop/niri).
          backdrop.enabled = true;

          bar.default = {
            position = "top";
            start = [
              "launcher"
              "workspaces"
            ];
            center = [ "active_window" ];
            end = [
              "network"
              "volume"
              "bluetooth"
              "battery"
              "wallpaper"
              "clock"
            ];
          };

          # The wallpaper widget only opens the picker out of the box, so the
          # gestures it leaves unused are bound to the wallpaper IPC commands.
          widget.wallpaper.actions = {
            left = "wallpaper-next";
            right = "wallpaper-random";
            middle = "panel-toggle wallpaper";
            scroll_up = "wallpaper-next";
            scroll_down = "wallpaper-previous";
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

          shell = {
            # Built-in polkit agent (niri's recommended authentication agent).
            polkit_agent = true;
            screenshot.directory = "${config.home.homeDirectory}/Pictures/screenshot";
          };
        };
      };
    };
}
