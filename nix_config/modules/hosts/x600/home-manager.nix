{ ... }:
{
  # Outputs are per host. Refresh with `niri msg outputs` and update here.
  flake.modules.homeManager."nixosConfigurations/armin-pc".wayland.windowManager.niri.settings._children = [
    {
      output = {
        _args = [ "DP-1" ];
        mode = "3840x2160";
        scale = 1.5;
        position._props = {
          x = 0;
          y = 0;
        };
      };
    }
  ];
}
