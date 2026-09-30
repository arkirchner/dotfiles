# The shared Ruby toolchain. Returns the definition rather than a shell:
# shells/rails-devenv.nix turns the same attribute set into a devenv module, so
# a devShell and a devenv get an identical environment.
{
  pkgs,
  extraBuildInputs ? [ ],
  extraLibPath ? [ ],
  extraShellEnv ? { },
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
rec {
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

  shellEnv = {
    BUNDLE_PATH = "$PWD/.bundle";
    GEM_HOME = "$PWD/.bundle";
    PATH = "$PWD/.bundle/bin:$PATH";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (nativeLibs ++ extraLibPath);
    RUBY_YJIT_ENABLE = "1";
  }
  // extraShellEnv;

  shellHook = ''
    ${pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (name: value: "export ${name}=${value}") shellEnv
    )}
  ''
  + extraShellHook;
}
