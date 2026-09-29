{ ... }:
{
  # Outputs are per host. Refresh with `niri msg outputs` and update here.
  flake.modules.homeManager."nixosConfigurations/armin-laptop".wayland.windowManager.niri.settings._children = [
    {
      output = {
        _args = [ "eDP-1" ];
        mode = "1920x1080";
        position._props = {
          x = 0;
          y = 0;
        };
      };
    }
  ];
}
