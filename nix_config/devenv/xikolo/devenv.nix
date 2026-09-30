# The xikolo dev environment, kept here rather than in the app repo: the repo's
# devenv.yaml pulls this in through its `imports` key and carries an empty
# devenv.nix, because devenv requires that file to exist in the project root.
#
# config.devenv.root is the *app* directory even though this file lives here, so
# .bundle, the postgres socket and $DEVENV_STATE all stay per-app.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Relative paths, so this resolves against this file inside the dotfiles input
  # rather than depending on the app naming that input.
  shells = ../../shells;
  base = import (shells + "/agent-xikolo.nix") { inherit pkgs; };
in
{
  imports = [
    (import (shells + "/rails-devenv.nix") {
      inherit base lib;
      root = config.devenv.root;
    })
  ];

  # The database this app needs, and nothing else: no host-level postgres, no
  # cluster outside $DEVENV_STATE.
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;

    # The names in config/database.yml, not one named after the user.
    createDatabase = false;
    initialDatabases = [
      {
        name = "xikolo";
      }
      {
        name = "xikolo_queue";
      }
      {
        name = "xikolo-test";
      }
    ];
  };

  # DATABASE_URL is deliberately not set. database.yml reads it per environment
  # and a single URL would override the distinct `database:` names, collapsing
  # the queue database into the primary one. PGHOST, which devenv points at
  # this project's socket, is enough.
}
