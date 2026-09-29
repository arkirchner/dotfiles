{
  perSystem =
    { pkgs, ... }:
    {
      # `nix develop nix_config#codeocean` / `#wave-walker`. The shell bodies
      # live in ../../shells; they take `pkgs` from here, so no NIX_PATH.
      devShells = {
        codeocean = import ../../shells/codeocean.nix { inherit pkgs; };
        wave-walker = import ../../shells/wave_walker.nix { inherit pkgs; };
      };
    };
}
