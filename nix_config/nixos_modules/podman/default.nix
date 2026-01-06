{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable common container config files in /etc/containers
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = false;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    docker = {
      enable = true;
      extraOptions = "--add-runtime=runsc=${pkgs.gvisor}/bin/runsc";

      # enableOnBoot = true;

      # daemon = {
      #   settings = {
      #     features = {
      #       buildkit = true;
      #     };
      #   };
      # };
    };
  };

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    # qemu_full
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
  ];

  # Required for docker buildx / ARM emulation
  # boot.kernelModules = [ "binfmt_misc" ];
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  systemd.services.qemu-user-static = {
    description = "Register QEMU static binaries for Docker ARM emulation";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker run --rm --privileged multiarch/qemu-user-static --reset -p yes";
      RemainAfterExit = true;
    };
  };
}
