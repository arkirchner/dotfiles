{
  description = "Dev shell Xikolo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-22_11.url = "github:NixOS/nixpkgs/22.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-22_11,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      legacy = import nixpkgs-22_11 { inherit system; };
      gtk_deps = with pkgs; [
        bun
        pkg-config
        cairo
        zlib
        libpng
        fontconfig
        freetype
        libx11
        libxext
        libxrender
        libxcb
        xorgproto
        libXau
        libXdmcp
        pixman
        expat
        bzip2
        brotli
        glib
        libffi
        libsysprof-capture
        pcre2
        gobject-introspection
        util-linux
        libselinux
        libsepol
        gdk-pixbuf
        librsvg
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs =
          with pkgs;
          [
            ruby_3_4
            postgresql_16
            libffi
            openssl
            libxml2
            libxslt
            zlib
            vips
            wget
            curl
            gnumake
            libyaml
            shared-mime-info
            icu
            libidn
            curl
            pkg-config
            cairo
            libpng
            corepack_24
            nodejs_24
            autoreconfHook
            autoconf
            automake
            libtool
            gifsicle
            optipng
            mozjpeg
            nasm
            dart
            python315
            ffmpeg
            patchelf
          ]
          ++ gtk_deps;

        shellHook = ''
          export NIX_LD=${pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"}
          export NIX_LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}
          export CFLAGS="-O2"
          export LDFLAGS="-lc"
          export HUSKY=0
          export BUNDLE_PATH=$PWD/.bundle
          export GEM_HOME=$PWD/.bundle
          export PATH=$PWD/.bundle/bin:$PATH
          export LD_LIBRARY_PATH=${
            pkgs.lib.makeLibraryPath (
              with pkgs;
              [
                icu
                vips
                libyaml
                postgresql_16
                libidn
                curl
                libsodium
                libpng
              ]
            )
          };
          export RUBY_YJIT_ENABLE=1;
          export FREEDESKTOP_MIME_TYPES_PATH="${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml"
          export PKG_CONFIG=${pkgs.pkg-config}/bin/pkg-config
          export PKG_CONFIG_PATH=${
            builtins.concatStringsSep ":" (map (p: "${p.dev or p}/lib/pkgconfig") gtk_deps)
          }:${pkgs.xorgproto}/share/pkgconfig:$PKG_CONFIG_PATH
        '';
      };
    };
}
