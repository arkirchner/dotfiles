{ config, ... }:
{
  flake.modules.homeManager.armin = {
    home.stateVersion = "24.05";

    imports = with config.flake.modules.homeManager; [
      home
      programs
      desktop-programs
    ];
  };
}
