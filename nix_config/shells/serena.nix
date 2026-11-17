# serena-agent is not in nixpkgs, so it runs through uvx, which downloads its
# own CPython. That build cannot start on NixOS, hence the pinned interpreter.
# LD_LIBRARY_PATH is extended rather than replaced, because serena also spawns
# the Ruby language server, which needs the app's libs.
{ pkgs }:

pkgs.writeShellScriptBin "serena-mcp" ''
  export UV_PYTHON_DOWNLOADS=never
  export UV_PYTHON=${pkgs.python313}/bin/python3
  export LD_LIBRARY_PATH=${
    pkgs.lib.makeLibraryPath [ pkgs.python313 ]
  }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
  exec ${pkgs.uv}/bin/uvx --from serena-agent serena start-mcp-server --context ide-assistant "$@"
''
