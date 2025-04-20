{config, pkgs, ... }: 
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["${../../../wallpapers/night-mountain.jpg}"];
      wallpaper = [",${../../../wallpapers/night-mountain.jpg}"];
    };
  };
}
