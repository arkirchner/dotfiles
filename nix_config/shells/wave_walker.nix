{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ruby_4_0
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
  ];

  shellHook = ''
    export BUNDLE_PATH=$PWD/.bundle
    export GEM_HOME=$PWD/.bundle
    export PATH=$PWD/.bundle/bin:$PATH
    export LD_LIBRARY_PATH=${
      pkgs.lib.makeLibraryPath (
        with pkgs;
        [
          vips
          libyaml
        ]
      )
    };
    export RUBY_YJIT_ENABLE=1;
  '';
}
