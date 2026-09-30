# Turns one of the rails-base definitions into a devenv module, so an app repo
# can take the same toolchain this flake's devShells use without restating it.
# Not a shell itself: pass the definition in, e.g.
#
#   imports = [ (import (dotfiles + "/shells/rails-devenv.nix") {
#     inherit base lib;
#     root = config.devenv.root;
#   }) ];
#
# devenv calls imported modules with no implicit arguments, so lib and the
# project root both have to be passed in. `root` is needed because devenv sets
# env vars verbatim and so cannot expand the $PWD that the shellHook relies on.
{
  base,
  root,
  lib,
  ...
}:

let
  resolved = lib.mapAttrs (_name: value: lib.replaceStrings [ "\$PWD" ] [ root ] value) base.shellEnv;
in
{
  packages = base.buildInputs;

  # PATH is the one value left unexpanded: the shell resolves its own $PATH
  # when the export below runs.
  env = lib.removeAttrs resolved [ "PATH" ];

  enterShell = ''
    export PATH=$PWD/.bundle/bin:$PATH
  '';
}
