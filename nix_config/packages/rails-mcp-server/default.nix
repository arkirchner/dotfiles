{
  pkgs ? import <nixpkgs> { },
}:

let
  env = pkgs.bundlerEnv {
    name = "rails-mcp-server-env";
    # The 4.0 series on purpose; nixpkgs `ruby` is still on 3.4.
    ruby = pkgs.ruby_4_0;
    gemdir = ./.; # Looks for Gemfile, Gemfile.lock, and gemset.nix here
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "rails-mcp-server";
  version = "1.5.1";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    # Keep user and project gems out of the server's Ruby environment.
    makeWrapper ${env}/bin/rails-mcp-server $out/bin/rails-mcp-server \
      --set GEM_HOME ${env}/${env.ruby.gemPath} \
      --set GEM_PATH ${env}/${env.ruby.gemPath}
  '';
}
