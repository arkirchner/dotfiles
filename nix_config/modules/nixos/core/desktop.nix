{ ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      services.dbus.enable = true;
      services.fwupd.enable = true;
      programs.dconf.enable = true;
      programs.steam.enable = true;

      xdg.portal = {
        enable = true;
        wlr.enable = false; # disable wlr if using Hyprland
        extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
        config.common.default = "hyprland";
      };

      services.greetd = {
        enable = true;
        settings = {
          initial_session = {
            command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.hyprland}/bin/start-hyprland";
            user = "armin";
          };

          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
          };
        };
      };

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
    };
}
