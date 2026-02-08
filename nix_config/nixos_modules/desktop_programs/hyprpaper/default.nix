{config, pkgs, ... }: 
{
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "${../../../wallpapers/night-mountain.jpg}";
        }
        {
          monitor = "DP-1";
          path = "${../../../wallpapers/night-mountain.jpg}";
        }
        {
          monitor = "DP-2";
          path = "${../../../wallpapers/night-mountain.jpg}";
        }
        {
          monitor = "DP-3";
          path = "${../../../wallpapers/night-mountain.jpg}";
        }
        {
          monitor = "DP-4";
          path = "${../../../wallpapers/night-mountain.jpg}";
        }
      ];
    };
  };
}
