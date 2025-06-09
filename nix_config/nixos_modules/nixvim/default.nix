{ config, pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.catppuccin.enable = true;

    globals = {
      mapleader = " ";
    };

    opts = {
      number = true;
      swapfile = false;
      backspace = "indent,eol,start";
      relativenumber = true;
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;
      wrap = false;
    };
  };
}

