{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./thunar
    ./postgresql
    ./podman
    ./virtualbox
    ./nomad
  ];
}
