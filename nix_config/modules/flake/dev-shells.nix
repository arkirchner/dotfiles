{
  perSystem =
    { pkgs, ... }:
    {
      # `nix develop nix_config#codeocean` / `#wave-walker` / `#agent-rails` /
      # `#agent-xikolo` / `#agent-dotfiles`. The shell bodies live in
      # ../../shells; they take `pkgs` from here, so no NIX_PATH.
      devShells = {
        codeocean = import ../../shells/codeocean.nix { inherit pkgs; };
        wave-walker = import ../../shells/wave_walker.nix { inherit pkgs; };
        # The agent-ready shells. Their .envrc entries use `use flake` on this
        # flake, which is what a Rails app outside this repo has to do.
        agent-rails = import ../../shells/agent-rails.nix { inherit pkgs; };
        agent-xikolo = import ../../shells/agent-xikolo.nix { inherit pkgs; };
        agent-dotfiles = import ../../shells/agent-dotfiles.nix { inherit pkgs; };
      };
    };
}
