{ config, lib, pkgs, ... }:
{
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];

  # Mount, trash, and other functionalities
  services.gvfs = {
    enable = true;
  };

  services.tumbler.enable = true; # Thumbnail support for images
}
