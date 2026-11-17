# The wave-walker dev environment, kept here rather than in the app repo. An app
# carries no devenv files at all. `devenv --from` reads devenv.nix from wherever
# it is told to, so the definition can live here.
#
# There is no database service: SQLite files live in the app's storage/
# directory, so config.devenv.root being the *app* directory is all that is
# needed and each clone keeps its own databases.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Relative paths, so this resolves against this file's own location and does
  # not depend on how the app named this input.
  shells = ../../shells;
  base = import (shells + "/wave_walker.nix") { inherit pkgs; };
in
{
  imports = [
    (import (shells + "/rails-devenv.nix") {
      inherit base lib;
      root = config.devenv.root;
    })
  ];
}
