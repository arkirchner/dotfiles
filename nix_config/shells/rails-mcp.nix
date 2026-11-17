# The MCP set a Rails app gets: the nix MCPs off, the Rails stack on. Returns
# the config derivation that a shell points OPENCODE_CONFIG at, so the app
# repos need no opencode config of their own.
{ pkgs }:

let
  railsMcpServer = pkgs.callPackage ../packages/rails-mcp-server { };

  serena = import ./serena.nix { inherit pkgs; };
in
pkgs.writeText "opencode-rails.json" (
  builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    mcp = {
      # Nix MCPs are pointless in a Rails app and cost context.
      nixos.enabled = false;
      rails = {
        type = "local";
        command = [ "${railsMcpServer}/bin/rails-mcp-server" ];
        # The global config leaves rails off; this is a Rails app, so opt in.
        enabled = true;
      };
      playwright = {
        type = "local";
        command = [ "${pkgs.playwright-mcp}/bin/playwright-mcp" ];
      };
      serena = {
        type = "local";
        command = [ "${serena}/bin/serena-mcp" ];
        # Relative to the workspace, so serena picks up the current app.
        cwd = ".";
        # First run downloads the Ruby language server, which is well over
        # the 5s default.
        timeout = 300000;
      };
    };
  }
)
