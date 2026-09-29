{ ... }:
{
  flake.modules.nixos.podman =
    { pkgs, ... }:
    {
      # Enable common container config files in /etc/containers
      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;

          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;

          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      # Useful other development tools
      environment.systemPackages = with pkgs; [
        dive # look into docker image layers
        podman-tui # status of containers in the terminal
        podman-compose # start group of containers for dev
      ];

      # Registers the binfmt handlers podman needs to run aarch64 images. This
      # used to also be done by running the multiarch/qemu-user-static image in
      # a privileged container on every boot, which the kernel interface above
      # makes redundant.
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
      ];
    };
}
