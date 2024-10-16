{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      size = 20;
      name = "JetBrains Mono Font";
    };

    themeFile = "Catppuccin-Macchiato";

    shellIntegration.enableBashIntegration = true;
  };
}
