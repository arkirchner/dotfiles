{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono";
    };

    shellIntegration.enableBashIntegration = true;
  };
}
