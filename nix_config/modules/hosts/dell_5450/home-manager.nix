{ ... }:
{
  # Outputs are per host. Refresh with `niri msg outputs` and update here.
  flake.modules.homeManager."nixosConfigurations/armin-work-laptop".wayland.windowManager.niri.settings._children =
    [
      {
        output = {
          _args = [ "eDP-1" ];
          mode = "1920x1080";
          position._props = {
            x = 1200;
            y = 1560;
          };
        };
      }
      {
        output = {
          _args = [ "DP-4" ];
          mode = "1920x1200";
          transform = "90";
          position._props = {
            x = 0;
            y = 0;
          };
        };
      }
      {
        output = {
          _args = [ "DP-3" ];
          mode = "1920x1200";
          position._props = {
            x = 1200;
            y = 360;
          };
        };
      }
    ];
}
