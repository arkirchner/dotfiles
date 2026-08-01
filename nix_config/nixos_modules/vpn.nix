{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.resolved.enable = true;
  services.openvpn.servers = {
    cloudVPN  = {
      autoStart = false;
      config = '' config /home/armin/vpn/openhpicloud.conf '';
      updateResolvConf = true;

      up = ''
        resolvectl dns $dev 10.231.0.41 10.231.0.42 10.231.0.43
        resolvectl domain $dev "~openhpi.cloud" "~openhpi.net" "~openhpicloud.de" "~xopic.de"
      '';

      down = ''
        resolvectl revert $dev
      '';
    };

    csiVPN = {
      autoStart = false;
      config = '' config /home/armin/vpn/SC_User.ovpn '';
      updateResolvConf = true;
    };
  };
}
