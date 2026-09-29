{
  config,
  ...
}:
{
  flake.modules.homeManager.desktop-programs = {
    imports = with config.flake.modules.homeManager; [
      niri
      noctalia
    ];

    programs = {
      imv.enable = true;
      mpv.enable = true;
    };

    services.easyeffects.enable = true;
  };
}
