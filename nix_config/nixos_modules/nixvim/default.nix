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

    extraPackages = [
      (pkgs.ruby_3_4.withPackages (ps: with ps; [ ruby-lsp ]))
    ];

    lsp = {
      servers = {
        ruby_lsp.enable = true;
        nil_ls.enable = true;
        yamlls.enable = true;
      };

      keymaps = [
        {
	  key = "K";
	  lspBufAction = "hover";
        }
	{
	  key = "<leader>gd";
	  lspBufAction = "definition";
	}
	{
	  key = "<leader>gr"; 
	  lspBufAction = "references";
        }
	{
          key = "<leader>gf"; 
          lspBufAction = "format";
	}
	{
          key = "<leader>ca";
          lspBufAction = "code_action";
	}
	{
          key = "<leader>rn"; 
          lspBufAction = "rename";
	}
      ];
    };

    plugins.lspconfig.enable = true;
  };
}

