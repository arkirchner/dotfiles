# Agent-ready shell for this repo. The nix and context7 MCPs are registered
# globally and rails is off by default (see modules/home/opencode/default.nix),
# so this shell needs no opencode config of its own.
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

}
