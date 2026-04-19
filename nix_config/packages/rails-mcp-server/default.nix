{ pkgs ? import <nixpkgs> {} }:

let
  env = pkgs.bundlerEnv {
    name = "rails-mcp-server-env";
    ruby = pkgs.ruby_4_0;
    gemdir = ./.; # Looks for Gemfile, Gemfile.lock, and gemset.nix here
  };
in pkgs.stdenv.mkDerivation {
  pname = "rails-mcp-server";
  version = "1.5.1";

  buildInputs = [ env ];

  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${env}/bin/rails-mcp-server $out/bin/rails-mcp-server
  '';
}