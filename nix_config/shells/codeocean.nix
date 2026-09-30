{ pkgs }:

import ./rails-base.nix {
  inherit pkgs;
  extraBuildInputs = with pkgs; [
    bun
    postgresql_16
    vips
    shared-mime-info
    icu
    nodejs_22
    corepack_22
    libidn
    pkg-config
    cairo
  ];
  # The C extensions in here link against more than the shared set.
  extraLibPath = with pkgs; [
    cairo
    curl
    icu
    libidn
    libsodium
    postgresql_16
    vips
  ];
  extraShellEnv = {
    OPENCODE_CONFIG = "${import ./rails-mcp.nix { inherit pkgs; }}";
  };
  extraShellHook = ''
    export FREEDESKTOP_MIME_TYPES_PATH="${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml"
  '';
}
