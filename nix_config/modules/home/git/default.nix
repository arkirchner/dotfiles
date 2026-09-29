{ ... }:
{
  flake.modules.homeManager.git =
    { ... }:
    {
      programs = {
        git = {
          enable = true;
          lfs.enable = true;

          settings = {
            core.editor = "nvim";
            commit.gpgsign = true;
            init.defaultBranch = "main";
            user.name = "Armin Kirchner";
            user.email = "post.armin@gmail.com";
            user.signingkey = "CB0A750597297FF3C6861AE11FED64228A24AF9E";
          };

          ignores = [
            "*~"
            "*.swp"
            "*.swo"
            ".direnv/"
          ];

          includes = [
            {
              condition = "hasconfig:remote.*.url:git@gitlab.hpi.de:*";
              contents.user.email = "armin.kirchner@hpi.de";
            }
          ];
        };
      };
    };
}
