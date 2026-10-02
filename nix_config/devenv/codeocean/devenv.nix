# The codeocean dev environment, kept here rather than in the app repo. An app
# carries no devenv files beyond a devenv.local.yaml: its .envrc is a single
# `use devenv --from` pointing at this directory, and that is enough. `devenv
# --from` reads devenv.nix from wherever it is told to, so the definition can
# live here.
#
# The one thing an app cannot get from here is allow_unfree: devenv reads that
# from YAML in the project root only, so codeocean carries a two-line
# devenv.local.yaml saying so. nomad is BSL.
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
  # Relative paths, so this resolves against this file's own location and does
  # not depend on how the app named this input.
  shells = ../../shells;
  base = import (shells + "/codeocean.nix") { inherit pkgs; };
in
{
  imports = [
    (import (shells + "/rails-devenv.nix") {
      inherit base lib;
      root = config.devenv.root;
    })
  ];

  # The CLI for the nomad process below, so `nomad job run` works from the shell.
  packages = [ pkgs.nomad ];

  # The names in config/database.yml. DATABASE_URL is deliberately not set: the
  # yml only reads host/port when DB_HOST is present, and PGHOST, which devenv
  # points at this project's socket, is enough to route every entry.
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;

    createDatabase = false;
    initialDatabases = [
      {
        name = "codeocean_development";
      }
      {
        name = "codeocean_development_cable";
      }
      {
        name = "codeocean_development_queue";
      }
      {
        name = "codeocean_test";
      }
    ];
  };

  # The nomad server and client the NixOS module used to describe, now scoped to
  # this project. -dev is a single-node server and client with in-memory state;
  # the data dir lives under $DEVENV_STATE rather than /var/lib/nomad.
  processes.nomad = {
    # DOCKER_HOST is exported here rather than in env because it has to be
    # resolved at spawn time: devenv's own config only knows its private runtime
    # dir, not the XDG one that podman puts its socket in. Expanding it in the
    # exec keeps the evaluation pure, so devenv can still cache it.
    exec = ''
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
      exec ${lib.getExe pkgs.nomad} agent -dev -data-dir ${config.devenv.state}/nomad
    '';

    restart.on = "always";
  };
}
