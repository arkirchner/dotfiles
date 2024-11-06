{ config, pkgs, lib, ... }:
{
  home = {
    sessionVariables = {
      RUBY_YJIT_ENABLE = "1";
      BUNDLE_PATH = "${config.home.homeDirectory}/.local/share/gem";
      # For ffi to find libvips.so.42
      LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [ vips ]);
    };

    packages = with pkgs; [
      ruby_3_3
      postgresql_16
      libyaml
      vips
      jemalloc
      geos
      proj
      exiftool
      libidn
      awscli2
      vegeta
      chromedriver
      chromium
    ];
  };
}
