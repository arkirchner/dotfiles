# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Fix netwerk issues caused by bluetooth on Ideapad 720s
  boot.extraModprobeConfig = "options rtw88_core disable_lps_deep=Y";

  # Disable buggy tpm2 driver (might be fixed in newer kernel)
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  networking.hostName = "armin-laptop"; # Define your hostname.
}
