{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 15;
    };

    settings = {
      background_opacity = "0.8";
    };

    theme = "Catppuccin-Mocha";
    shellIntegration.enableBashIntegration = true;
  };
}
