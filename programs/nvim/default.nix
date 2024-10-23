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
      vim-test
      vimux
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./copilot.lua}
      ${builtins.readFile ./vim_test.lua}
      ${builtins.readFile ./vimux.lua}
    '';
  };
}
