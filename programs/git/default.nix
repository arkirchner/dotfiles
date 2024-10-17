{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;

    userName = "Armin Kirchner";
    userEmail = "post.armin@gmail.com";

    aliases = {
      hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
    };

    ignores = [
      "*~"
      "*.swp"
      "*.swo"
    ];

    extraConfig = {
      core.editor = "nvim";
      commit.gpgsign = true;
      init.defaultBranch = "main";
    };
  };
}
