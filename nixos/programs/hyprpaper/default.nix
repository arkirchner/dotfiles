{config, pkgs, ... }: 
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["${../../../wallpapers/cabin-5.png}"];
      wallpaper = [",${../../../wallpapers/cabin-5.png}"];
    };
  };
}
