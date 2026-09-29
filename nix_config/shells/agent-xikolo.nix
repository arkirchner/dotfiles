# Agent-ready shell for the xikolo apps. Same MCP set as agent-rails; the extra
# packages are the ones xikolo needs to build its CSS and image pipelines.
{ pkgs }:

let
  # sass-embedded and the image tooling link against GTK/cairo/pango.
  gtkDeps = with pkgs; [
    bzip2
    brotli
    cairo
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gobject-introspection
    kind
    libXau
    libXdmcp
    libffi
    libpng
    librsvg
    libselinux
    libsepol
    libsysprof-capture
    libx11
    libxcb
    libxext
    libxrender
    pcre2
    pixman
    util-linux
    xorgproto
    zlib
  ];
in
import ./rails-base.nix {
  inherit pkgs;
  extraBuildInputs =
    with pkgs;
    [
      nodejs_24
      corepack_24
      bun
      playwright-mcp
      postgresql_16
      shared-mime-info
      icu
      libidn
      pkg-config
      cairo
      libpng
      # sass-embedded builds from source.
      autoreconfHook
      autoconf
      automake
      libtool
      # Image optimisation.
      gifsicle
      optipng
      mozjpeg
      ffmpeg
      nasm
      dart
      python315
      # Node native addons.
      patchelf
      vips
    ]
    ++ gtkDeps;

  # The C extensions in here link against more than the shared set.
  extraLibPath = with pkgs; [
    cairo
    curl
    icu
    libidn
    libpng
    libsodium
    postgresql_16
    vips
  ];

  extraShellHook = ''
    export NIX_LD=${pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"}
    export NIX_LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}
    export CFLAGS="-O2"
    export LDFLAGS="-lc"
    export HUSKY=0
    export FREEDESKTOP_MIME_TYPES_PATH="${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml"
    export PKG_CONFIG=${pkgs.pkg-config}/bin/pkg-config
    export PKG_CONFIG_PATH=${
      builtins.concatStringsSep ":" (map (p: "${p.dev or p}/lib/pkgconfig") gtkDeps)
    }:${pkgs.xorgproto}/share/pkgconfig:$PKG_CONFIG_PATH
    export OPENCODE_CONFIG=${import ./rails-mcp.nix { inherit pkgs; }}
  '';
}
