# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ] ++ (import ./system_programs);

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Fix netwerk issues caused by bluetooth on Ideapad 720s
  boot.extraModprobeConfig = "options rtw88_core disable_lps_deep=Y";

  # Disable buggy tpm2 driver (might be fixed in newer kernel)
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "Hyprland";
        user = "armin";
      };

      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      };
    };
  };


  # Hardware exelerated graphics.
  hardware.graphics = {
    enable = true;
  };

  # Enable bluetooth support.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Sound configuration
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.armin = { config, pkgs, lib, ...}: {

    home.packages = with pkgs; [
      tmux
      firefox
      chromedriver
      chromium
      kitty
      gnupg
      cmus
      pass
      kubectl
      kubernetes-helm
      tenv
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
    samba
    lxqt.lxqt-policykit
  ];

  security.pam.u2f = {
    enable = true;

    settings = {
      interactive = true;
      cue = true;

      origin = "pam://yubi";
      authFile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
        "armin"
        ":YOraJfl9LTreqCp+xoW/Xs/yJy+EYo1nc63FjkCXGs7jtZeWHXlw0zWeyrYCfspwZflaPqDlK5s4ZsfUSk4Eqw==,7tBOY1igcf49G+7VXQ0m1E7A4irWnnKhfqQosBJb2TwkYdKAvFM2LkUJKPc613+8FhSfDLyv87LNGFKGAzeFDg==,es256,+presence"
        ":DeJhZjWWn+4IP5/+0wRZOjZHJHvpE9dlybdnVUE7Z7+oXPRfm5MOqSKKxCxXm8uz+4hsXP0s4Da3Mu7r9fx8pA==,9Oq8pLO14qK/9bOu4uLLL+l0gu+iVUNlMv+U2TwN0MvsephwJg75yNWImVT7SsuSeZTnjWnBkidh1Sg2zskzFA==,es256,+presence"
      ]);
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # Enable wayland support for chromium and electron
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
 
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
  # Allow SMTP discovery
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
