{ ... }:
{
  flake.modules.nixos.nomad =
    { pkgs, ... }:
    {
      services.nomad = {
        enable = true;
        extraSettingsPlugins = [ pkgs.nomad-driver-podman ];

        settings = {
          client = {
            enabled = true;
            alloc_dir = "/var/lib/nomad/alloc_mounts";
          };
          server = {
            enabled = true;
            bootstrap_expect = 1;
            default_scheduler_config = {
              scheduler_algorithm = "spread";
              memory_oversubscription_enabled = true;
            };
          };

          plugin = [
            {
              nomad-driver-podman = {
                config = { };
              };
            }
          ];
        };
      };

      # `StateDirectory` only covers /var/lib/nomad itself; the client needs
      # alloc_dir to exist before it starts mounting allocation volumes.
      systemd.tmpfiles.settings."nomad"."/var/lib/nomad/alloc_mounts".d.mode = "0700";
    };
}
