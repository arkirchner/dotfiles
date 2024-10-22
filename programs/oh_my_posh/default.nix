{ config, pkgs, ... }:
{
  programs.oh-my-posh = {
    enable = true;

    enableBashIntegration = true;
    useTheme = "kali";
  };
}
