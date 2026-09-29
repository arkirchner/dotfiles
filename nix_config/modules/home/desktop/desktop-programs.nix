{ config, ... }:
{
  flake.modules.homeManager.desktop-programs = {
    imports = with config.flake.modules.homeManager; [
      niri
      noctalia
      imv
      mpv
      easyeffects
    ];
  };
}
