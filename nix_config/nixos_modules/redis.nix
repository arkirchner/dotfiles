{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.redis.servers.main = {
    port = 6379;
    enable = true;
    databases = 8192;
  };
}
