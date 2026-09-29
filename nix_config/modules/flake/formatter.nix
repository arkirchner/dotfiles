{
  perSystem =
    { pkgs, ... }:
    {
      # `nix fmt`. The rule set lives in ../../treefmt.toml so it can also be
      # run directly as `treefmt --config-file treefmt.toml`.
      formatter = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = [
          pkgs.treefmt
          pkgs.nixfmt
          pkgs.deadnix
        ];
        text = ''
          exec treefmt --config-file ${../../treefmt.toml} "$@"
        '';
      };
    };
}
