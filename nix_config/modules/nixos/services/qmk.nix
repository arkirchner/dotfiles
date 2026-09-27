{ ... }:
{
  flake.modules.nixos.qmk =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        qmk
        via
      ];
      hardware.keyboard.qmk.enable = true;
      services.udev.packages = [ pkgs.via ];
    };
}
