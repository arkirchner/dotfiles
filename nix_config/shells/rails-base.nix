# Shared toolchain for the Rails apps. Not a shell on its own: the per-app
# shells import it and pass only what is specific to them.
{
  pkgs,
  extraBuildInputs ? [ ],
  extraLibPath ? [ ],
  extraShellHook ? "",
}:

let
  # What the native gems link against. Listed separately from buildInputs
  # because mkShell does not derive LD_LIBRARY_PATH for us, and ruby, node
  # and the like have no business on the library path.
  nativeLibs = with pkgs; [
    libffi
    libxml2
    libxslt
    libyaml
    openssl
    zlib
  ];
in
pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      # The 4.0 series on purpose; nixpkgs `ruby` is still on 3.4.
      ruby_4_0
      wget
      curl
      gnumake
    ]
    ++ nativeLibs
    ++ extraBuildInputs;

  shellHook = ''
    export BUNDLE_PATH=$PWD/.bundle
    export GEM_HOME=$PWD/.bundle
    export PATH=$PWD/.bundle/bin:$PATH
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath (nativeLibs ++ extraLibPath)}
    export RUBY_YJIT_ENABLE=1
  ''
  + extraShellHook;
}
