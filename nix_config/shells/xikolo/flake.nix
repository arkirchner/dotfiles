{
  description = "Dev shell Xikolo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      gtk_deps = with pkgs; [
        pkg-config
        cairo
        zlib
        libpng
        fontconfig
        freetype
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libxcb
        xorg.xorgproto
        xorg.libXau
        xorg.libXdmcp
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
            nodejs_22
            corepack_22
            libidn
            curl
            pkg-config
            cairo
            libpng
          ]
          ++ gtk_deps;

        shellHook = ''
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
          }:${pkgs.xorg.xorgproto}/share/pkgconfig:$PKG_CONFIG_PATH
        '';
      };
    };
}
