{
  writeShellApplication,
  nodejs_24,
  chromium,
  stdenv,
  lib,
}:

writeShellApplication {
  name = "docs-mcp-server";
  runtimeInputs = [ nodejs_24 ];

  text = ''
    export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH="${chromium}/bin/chromium"
    export LD_LIBRARY_PATH="${
      lib.makeLibraryPath [ stdenv.cc.cc.lib ]
    }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export DOCS_MCP_TELEMETRY=false
    exec npx --yes @arabold/docs-mcp-server@3.2.1 mcp --protocol stdio
  '';
}
