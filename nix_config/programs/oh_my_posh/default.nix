{ config, pkgs, ... }:
{
  programs.oh-my-posh = {
    enable = true;
    enableBashIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./catppuccin.omp.json);
  };
}
