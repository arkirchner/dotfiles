{ inputs, ... }:
{
  flake.modules.homeManager.codex =
    { pkgs, ... }:
    let
      docsMcpServer = pkgs.callPackage ../../packages/docs-mcp-server { };
      railsMcpServer = pkgs.callPackage ../../packages/rails-mcp-server { };
      serena = import ../../shells/serena.nix { inherit pkgs; };
      skills = "${inputs.rails-consultant}/skills";
    in
    {
      programs.codex = {
        enable = true;
        skills = skills;
        # Codex writes project trust levels back into config.toml, so the file
        # must be writable, not a symlink into the Nix store.
        mutableSettings = true;
        settings = {
          mcp_servers = {
            docs-mcp-server = {
              command = "${docsMcpServer}/bin/docs-mcp-server";
              startup_timeout_sec = 120;
            };
            playwright = {
              command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
              args = [ "--headless" ];
            };
            rails = {
              command = "${railsMcpServer}/bin/rails-mcp-server";
            };
            serena = {
              command = "${serena}/bin/serena-mcp";
              # MCP stdio servers inherit only selected environment variables.
              # Ruby LSP needs the active Rails shell's gems and native libraries.
              env_vars = [
                "GEM_HOME"
                "GEM_PATH"
                "BUNDLE_PATH"
                "LD_LIBRARY_PATH"
              ];
              # First run downloads the Ruby language server, which is well
              # over Codex's default startup timeout.
              startup_timeout_sec = 300;
            };
          };
        };
      };
    };
}
