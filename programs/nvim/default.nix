{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;

    extraPackages = with pkgs; [
      nil
      marksman
      lua-language-server
      yaml-language-server
      ltex-ls
      rubyPackages_3_3.ruby-lsp
      rubyPackages_3_3.rubocop
      nodePackages.bash-language-server
    ];

    plugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
      copilot-lua
      vim-test
      vimux
      nvim-lspconfig
      lspkind-nvim
      nvim-treesitter.withAllGrammars
      lualine-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      luasnip
      cmp_luasnip
      friendly-snippets
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./copilot.lua}
      ${builtins.readFile ./vim_test.lua}
      ${builtins.readFile ./vimux.lua}
      ${builtins.readFile ./lspconf.lua}
      ${builtins.readFile ./treesitter.lua}
    '';
  };
}
