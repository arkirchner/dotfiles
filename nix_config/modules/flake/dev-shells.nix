{
  perSystem =
    { pkgs, ... }:
    let
      # The Rails shell bodies return a { buildInputs, shellEnv, shellHook }
      # definition rather than a shell, so that shells/rails-devenv.nix can hand
      # the same one to a devenv. mkShell gets only the two fields it wants;
      # passing the whole set would have stdenv coerce shellEnv into an env var.
      mkRailsShell =
        path: args:
        let
          base = import path args;
        in
        pkgs.mkShell {
          inherit (base) buildInputs;
          shellHook = base.shellHook;
        };
    in
    {
      # `nix develop nix_config#codeocean` / `#wave-walker` / `#agent-rails` /
      # `#agent-xikolo` / `#agent-dotfiles`. The bodies live in ../../shells;
      # they take `pkgs` from here, so no NIX_PATH.
      devShells = {
        codeocean = mkRailsShell ../../shells/codeocean.nix { inherit pkgs; };
        wave-walker = mkRailsShell ../../shells/wave_walker.nix { inherit pkgs; };
        # The agent-ready shells. Their .envrc entries use `use flake` on this
        # flake, which is what a Rails app outside this repo has to do.
        agent-rails = mkRailsShell ../../shells/agent-rails.nix { inherit pkgs; };
        agent-xikolo = mkRailsShell ../../shells/agent-xikolo.nix { inherit pkgs; };
        agent-dotfiles = import ../../shells/agent-dotfiles.nix { inherit pkgs; };
      };
    };
}
