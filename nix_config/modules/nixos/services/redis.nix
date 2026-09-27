{ ... }:
{
  flake.modules.nixos.redis = {
    services.redis.servers.main = {
      port = 6379;
      enable = true;
      databases = 8192;
    };
  };
}
