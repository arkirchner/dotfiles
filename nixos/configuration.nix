# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
    ] ++ (import ./system_programs);

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.armin = {
    isNormalUser = true;
    description = "Armin Kirchner";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "armin";

  home-manager.users.armin = { config, pkgs, lib, ...}: {
    home.packages = with pkgs; [
      hyprland
      tmux
      firefox
      kitty
      gnupg
    ];

    imports = (import ../programs) ++ (import ./programs);

    home.stateVersion = "24.05";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  security.pam.u2f = {
    enable = true;
    interactive = true;
    cue = true;

    origin = "pam://yubi";
    authFile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
      "armin"
      ":YOraJfl9LTreqCp+xoW/Xs/yJy+EYo1nc63FjkCXGs7jtZeWHXlw0zWeyrYCfspwZflaPqDlK5s4ZsfUSk4Eqw==,7tBOY1igcf49G+7VXQ0m1E7A4irWnnKhfqQosBJb2TwkYdKAvFM2LkUJKPc613+8FhSfDLyv87LNGFKGAzeFDg==,es256,+presence"
      ":DeJhZjWWn+4IP5/+0wRZOjZHJHvpE9dlybdnVUE7Z7+oXPRfm5MOqSKKxCxXm8uz+4hsXP0s4Da3Mu7r9fx8pA==,9Oq8pLO14qK/9bOu4uLLL+l0gu+iVUNlMv+U2TwN0MvsephwJg75yNWImVT7SsuSeZTnjWnBkidh1Sg2zskzFA==,es256,+presence"
    ]);
  };

  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
 
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
