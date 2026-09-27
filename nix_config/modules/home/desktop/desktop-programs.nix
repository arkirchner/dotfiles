{ config, ... }:
{
  flake.modules.homeManager.desktop-programs = {
    imports = with config.flake.modules.homeManager; [
      hyprland
      waybar
      wofi
      hyprpaper
      imv
      mpv
      easyeffects
    ];
  };
}
