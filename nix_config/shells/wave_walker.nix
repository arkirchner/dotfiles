{ pkgs }:

import ./rails-base.nix {
  inherit pkgs;
  extraBuildInputs = with pkgs; [ vips ];
  extraLibPath = with pkgs; [ vips ];
  extraShellEnv = {
    # This is a Rails app, so opt in to the Rails MCP set that is off globally.
    OPENCODE_CONFIG = "${import ./rails-mcp.nix { inherit pkgs; }}";
  };
}
