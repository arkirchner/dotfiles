{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
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
  ];

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
        ]
      )
    };
    export RUBY_YJIT_ENABLE=1;
    export FREEDESKTOP_MIME_TYPES_PATH="${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml"
  '';
}
