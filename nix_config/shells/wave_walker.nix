{ pkgs }:

import ./rails-base.nix {
  inherit pkgs;
  extraBuildInputs = with pkgs; [
    vips
    # AI coding assistants run Python skills here; their validator imports yaml.
    (python3.withPackages (ps: [ ps.pyyaml ]))
  ];
  extraLibPath = with pkgs; [ vips ];
  extraShellEnv = {
    # This is a Rails app, so opt in to the Rails MCP set that is off globally.
    OPENCODE_CONFIG = "${import ./rails-mcp.nix { inherit pkgs; }}";
  };
}
