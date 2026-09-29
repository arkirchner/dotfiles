{ config, ... }:
{
  flake.modules.homeManager.desktop-programs = {
    imports = with config.flake.modules.homeManager; [
      hyprland
      niri
      noctalia
      waybar
      wofi
      hyprpaper
      imv
      mpv
      easyeffects
    ];
  };
}
