{config, pkgs, ... }: 
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["${./cabin-5.png}"];
      wallpaper = [",${./cabin-5.png}"];
    };
  };
}
