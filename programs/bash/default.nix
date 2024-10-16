{ config, pkgs, ... }:

let tatConfig = "${builtins.readFile ../../linux/.bashrc.d/tmux}";
in
{
  programs.bash = {
    enable = true;

    bashrcExtra = ''
      ${tatConfig}
    '';
  };
}
