# The MCP set a Rails app gets: the nix MCPs off, the Rails stack on. Returns
# the config derivation that a shell points OPENCODE_CONFIG at, so the app
# repos need no opencode config of their own.
{ pkgs }:

let
  railsMcpServer = pkgs.callPackage ../packages/rails-mcp-server { };

  # serena-agent is not in nixpkgs, so it runs through uvx, which downloads its
  # own CPython. That build cannot start on NixOS, hence the pinned
  # interpreter. LD_LIBRARY_PATH is extended rather than replaced, because
  # serena also spawns the Ruby language server, which needs the app's libs.
  serena = pkgs.writeShellScriptBin "serena-mcp" ''
    export UV_PYTHON_DOWNLOADS=never
    export UV_PYTHON=${pkgs.python313}/bin/python3
    export LD_LIBRARY_PATH=${
      pkgs.lib.makeLibraryPath [ pkgs.python313 ]
    }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    exec ${pkgs.uv}/bin/uvx --from serena-agent serena start-mcp-server --context ide-assistant "$@"
  '';
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
