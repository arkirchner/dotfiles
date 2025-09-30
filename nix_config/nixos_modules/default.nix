{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./thunar
    ./postgresql
    ./podman
    ./virtualbox
    ./nomad
    inputs.home-manager.nixosModules.default
    ./nvf.nix
    ./qmk.nix
    ./rabbitmq.nix
    ./redis.nix
    ./minio.nix
    ./vpn.nix
  ];

  # Plymouth setup
  boot = {
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.dbus.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-generations +5";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = false; # disable wlr if using Hyprland
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    config.common.default = "hyprland";
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.hyprland}/bin/Hyprland";
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

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.armin =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
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
        snx-rs
        overmind
        gimp3
      ];

      imports = (import ../programs) ++ (import ./desktop_programs);

      home.stateVersion = "24.05";
    };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    samba
    lxqt.lxqt-policykit
    slack
    zoom-us
  ];

  security.pam.u2f = {
    enable = true;

    settings = {
      interactive = true;
      cue = true;

      origin = "pam://yubi";
      authFile = pkgs.writeText "u2f-mappings" (
        lib.concatStrings [
          "armin"
          ":YOraJfl9LTreqCp+xoW/Xs/yJy+EYo1nc63FjkCXGs7jtZeWHXlw0zWeyrYCfspwZflaPqDlK5s4ZsfUSk4Eqw==,7tBOY1igcf49G+7VXQ0m1E7A4irWnnKhfqQosBJb2TwkYdKAvFM2LkUJKPc613+8FhSfDLyv87LNGFKGAzeFDg==,es256,+presence"
          ":DeJhZjWWn+4IP5/+0wRZOjZHJHvpE9dlybdnVUE7Z7+oXPRfm5MOqSKKxCxXm8uz+4hsXP0s4Da3Mu7r9fx8pA==,9Oq8pLO14qK/9bOu4uLLL+l0gu+iVUNlMv+U2TwN0MvsephwJg75yNWImVT7SsuSeZTnjWnBkidh1Sg2zskzFA==,es256,+presence"
        ]
      );
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  environment.sessionVariables = {
    # Enable wayland support for chromium and electron
    NIXOS_OZONE_WL = "1";
    CONTAINERD_ENABLE_DEPRECATED_PULL_SCHEMA_1_IMAGE = "1";
  };

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

  # Allow experimental nix features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
