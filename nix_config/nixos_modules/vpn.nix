{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.openvpn.servers = {
    cloudVPN  = {
      config = '' config /home/armin/vpn/openhpicloud.conf '';
      updateResolvConf = true;
    };
  };
}
