{ ... }:
{
  flake.modules.homeManager.codex =
    { pkgs, ... }:
    let
      railsMcpServer = pkgs.callPackage ../../packages/rails-mcp-server { };
      serena = import ../../shells/serena.nix { inherit pkgs; };
    in
    {
      programs.codex = {
        enable = true;
        # Codex writes project trust levels back into config.toml, so the file
        # must be writable, not a symlink into the Nix store.
        mutableSettings = true;
        settings = {
          mcp_servers = {
            context7 = {
              command = "${pkgs.context7-mcp}/bin/context7-mcp";
            };
            rails = {
              command = "${railsMcpServer}/bin/rails-mcp-server";
            };
            serena = {
              command = "${serena}/bin/serena-mcp";
              # First run downloads the Ruby language server, which is well
              # over Codex's default startup timeout.
              startup_timeout_sec = 300;
            };
          };
        };
      };
    };
}
