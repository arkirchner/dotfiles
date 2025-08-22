{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.redis.servers.main = {
    enable = true;
    databases = 8192;
  };
}
