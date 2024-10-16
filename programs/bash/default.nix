{ config, pkgs, ... }:
{
  programs.bash = {
    enable = true;

    # shellAliases = {
    #   ...config.programs.bash.shellAliases
    #   ...config.home.shellAliases
    # };
  };
}
