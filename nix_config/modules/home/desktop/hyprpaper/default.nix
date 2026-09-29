{ ... }:
{
  flake.modules.homeManager.hyprpaper =
    { ... }:
    {
      services.hyprpaper = {
        enable = true;
        # Hyprland-only tool; keep it off graphical-session.target so it does
        # not start (and fail-loop) under the niri session during the
        # parallel phase. niri uses Noctalia's wallpaper instead.
        systemdTarget = "hyprland-session.target";
        settings = {
          wallpaper = [
            {
              monitor = "eDP-1";
              path = "${../../../../wallpapers/night-mountain.jpg}";
            }
            {
              monitor = "DP-1";
              path = "${../../../../wallpapers/night-mountain.jpg}";
            }
            {
              monitor = "DP-2";
              path = "${../../../../wallpapers/night-mountain.jpg}";
            }
            {
              monitor = "DP-3";
              path = "${../../../../wallpapers/night-mountain.jpg}";
            }
            {
              monitor = "DP-4";
              path = "${../../../../wallpapers/night-mountain.jpg}";
            }
          ];
        };
      };
    };
}
