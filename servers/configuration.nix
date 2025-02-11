{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    tmp.cleanOnBoot = true;
    kernelModules = [ "rbd" ];
  };

  zramSwap.enable = true;
  networking.hostName = "vmi2124375";
  networking.domain = "contaboserver.net";

  services = {
    openssh = {
      enable = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        AllowUsers = [ "armin" ];
      };
    };

    k3s = {
      enable = true;
      role = "server";
      gracefulNodeShutdown.enable = true;
      extraFlags = [
        "--disable=traefik"
      ];
    };
  };

  # Allow SSH agent forwarding for sudo etc.
  security.pam.sshAgentAuth.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      6443  # k3s: API server
      10250 # k3s: metrics server
    ];
    allowedUDPPortRanges = [];
  };

  users.users.armin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDk6lh+6q3VKoG2nQDiiNaspLszxXKEH5t4/y2NBXW94WUD6lx0vMHpw2H4kzv796N7oCnlTKqLT/L6Jz1I9CURjYVxGDLDoJ8cc9vX0nil56uIYkSR2oY/5bdQIbAuQjFbGWQBqkkOL/iV0JPI0vZiQXq2QL4dD6YTG6qHP61EVCQGwAGcCiFsqCc7csjXhcgeghVcVTBxLvRsbtko/jd40FW9Lc1j1klZH2MM+tQ0JlsHBlZKkDOmMNRRBY7SeEkmmElmdP4XIDV6ww2OUHeLGM5HAcqWy/VMG1Ssk7T64Bk2SCgKyF12i39crK90r4NbywPM5no5SCSWSuAMzXLrw6b3YOVMFXw90x+sd5w0UZAMidjH7m7dFLNFErv0933Z/ulujmbQTEvGvaJ9nEpzcBApvwbNekXvQfjM3uA1mi0z6FcWENBBbAQHCqpveM8xZJ9XtCig2fHi5F+3T4hnj0C4XVYLHUMxFJD2Pb3U7KjkA3fuQl1XUz3MrSYsOfKX3E6j9jwXRvvAYbtBdPxcI1QsLw4QDYa49zs3JI3NoP6B5KAa9TRsn1y/9L/2hZPdBMEPCNRxfeY0pc/dJS+m9FHljLYPK55K8Wo+N9U3ZVdoB7+1KhPXs1PbYsPQRn1ggeP1yOr1qNxFbLM32VWCcilqrJG5lFfKy326J0LO2Q== cardno:23_453_732'' ];
  };

  system.stateVersion = "23.11";
}
