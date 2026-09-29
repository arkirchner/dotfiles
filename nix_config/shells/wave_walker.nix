{ pkgs }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # The 4.0 series on purpose; nixpkgs `ruby` is still on 3.4.
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
