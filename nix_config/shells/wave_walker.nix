{ pkgs }:

import ./rails-base.nix {
  inherit pkgs;
  extraBuildInputs = with pkgs; [ vips ];
  extraLibPath = with pkgs; [ vips ];
}
