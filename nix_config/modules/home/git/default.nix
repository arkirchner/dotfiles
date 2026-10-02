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

          # Home Manager writes these to ~/.config/git/ignore and points
          # core.excludesFile at it, so they apply in every repository rather
          # than needing each repo's own .gitignore touched.
          #
          # devenv writes devenv.lock and .devenv/ into the project root, and
          # an app here holds its devenv.local.yaml, which by devenv's own
          # convention is machine-local. None of the three belongs in a commit.
          # devenv.yaml and devenv.nix are deliberately absent: those are meant
          # to be committed in a project that uses them.
          ignores = [
            "*~"
            "*.swp"
            "*.swo"
            ".direnv/"
            ".devenv/"
            "devenv.lock"
            "devenv.local.yaml"
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
