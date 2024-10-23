{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
      copilot-lua
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./copilot.lua}
    '';
  };
}
