{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.openvpn.servers = {
    cloudVPN  = {
      autoStart = false;
      config = '' config /home/armin/vpn/openhpicloud.conf '';
      updateResolvConf = true;
    };
  };
}
