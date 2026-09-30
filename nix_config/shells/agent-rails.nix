# Agent-ready shell for the Rails apps. The MCP set is delivered to opencode
# through OPENCODE_CONFIG, which sits between the global and the project config
# in the precedence order, so nothing in the app repos has to change.
#
# This returns the definition, not a shell: dev-shells.nix wraps it in mkShell,
# and an app's devenv.nix imports it through shells/rails-devenv.nix.
{ pkgs }:

import ./rails-base.nix {
  inherit pkgs;
  extraBuildInputs = with pkgs; [
    # Nearly every app in here has a package.json next to its Gemfile.
    nodejs_22
    postgresql_16
    # Ships its own browser via PLAYWRIGHT_BROWSERS_PATH, so no browser needs
    # to be on the shell.
    playwright-mcp
  ];
  extraLibPath = with pkgs; [ postgresql_16 ];
  extraShellEnv = {
    OPENCODE_CONFIG = "${import ./rails-mcp.nix { inherit pkgs; }}";
  };
}
