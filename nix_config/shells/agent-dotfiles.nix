# Agent-ready shell for this repo. The nix MCP is registered globally (see
# modules/home/opencode/default.nix); the only thing this shell has to do is
# turn off the Rails MCP, which is dead weight here.
{ pkgs }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nix LSP: opencode has lsp = true, and nil is the Nix server.
    nil
    statix
    deadnix
    # Plain CLI tooling.
    git
    jq
    ripgrep
    yq
  ];

  shellHook = ''
    export OPENCODE_CONFIG=${
      pkgs.writeText "opencode-dotfiles.json" (
        builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";
          mcp.rails.enabled = false;
        }
      )
    }
  '';
}
