{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.garage = {
    enable = true;
    package = pkgs.garage;
    settings = {
      data_dir = "/var/lib/garage/data";
      metadata_dir = "/var/lib/garage/meta";
      replication_factor = 1;
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";
      rpc_secret = "1799bccfd7411eddcf9ebd316bc1f5287ad12a68094e1c6ac6abde7e6feae1ec";
      s3_api = {
        s3_region = "us-east-1";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.localhost";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage.localhost";
        index = "index.html";
      };
    };
  };

  # Automatically provision the minioadmin credentials to mimic MinIO's defaults
  systemd.services.garage.postStart = ''
    # Wait briefly for the Garage RPC socket to be available
    sleep 3
    ${pkgs.garage}/bin/garage key import minioadmin minioadmin || true
    ${pkgs.garage}/bin/garage key allow --create-bucket minioadmin || true
  '';
}
