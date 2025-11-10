{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "Armin Kirchner";
          email = "post.armin@gmail.com";
        };
      };


      ignores = [
        "*~"
        "*.swp"
        "*.swo"
        ".direnv/"
      ];

      extraConfig = {
        core.editor = "nvim";
        commit.gpgsign = true;
        init.defaultBranch = "main";
        user.signingkey = "CB0A750597297FF3C6861AE11FED64228A24AF9E";
      };

      includes = [
        {
          condition = "hasconfig:remote.*.url:git@gitlab.hpi.de:*";
          contents.user.email = "armin.kirchner@hpi.de";
        }
      ];
    };

    diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
