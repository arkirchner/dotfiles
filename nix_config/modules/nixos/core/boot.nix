{ ... }:
{
  flake.modules.nixos.boot =
    { pkgs, ... }:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # A graphical boot. plymouth holds the console from the initrd, through
      # the LUKS prompt, to the Noctalia greeter, and these stop the kernel and
      # systemd from painting over it in the meantime.
      boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        # The equivalent of systemd.showStatus, which this nixpkgs no longer
        # exposes as an option.
        "systemd.show_status=false"
        # Keeps Ctrl+Alt+F1..F12 working, so a back console is reachable even
        # while the splash has the VT.
        "vt.global_kbd_mode=1"
      ];

      boot.plymouth = {
        enable = true;

        # Matches the Catppuccin GTK theme the desktop already uses. The package
        # ships this one flavour.
        theme = "catppuccin-macchiato";
        themePackages = [ pkgs."catppuccin-plymouth" ];
      };
    };
}
