{ ... }:
{
  flake.modules.nixos.desktop = {
    services.dbus.enable = true;
    services.fwupd.enable = true;
    programs.dconf.enable = true;
    programs.steam.enable = true;

    # Session/portal backend is owned by programs.niri; the login session is
    # chosen by the Noctalia greeter (services.displayManager.noctalia-greeter).
    xdg.portal.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
