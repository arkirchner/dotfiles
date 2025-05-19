{ config, lib, pkgs, ... }:
{
  services.nomad = {
    enable = true;
    extraSettingsPlugins = [pkgs.nomad-driver-podman];

    settings = {
      client = {
        enabled = true;
        # TODO: I needed to create /var/lib/alloc_mounts for nomad to start ...
        alloc_dir = "/var/lib/nomad/allococ_mounts";
      };
      server = {
        enabled = true;
        bootstrap_expect = 1;
        default_scheduler_config = {
          scheduler_algorithm = "spread";
          memory_oversubscription_enabled = true;
        };
      };

      plugin = [{
        nomad-driver-podman = {
          config = { };
        };
      }];
    };
  };
}
