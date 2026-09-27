{ ... }:
{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      programs.fish.enable = true;

      users.users.armin = {
        isNormalUser = true;
        description = "Armin Kirchner";
        shell = pkgs.fish;
        # Keep the systemd user manager alive after logout so the Hermes user
        # service (dashboard/backend) keeps running.
        linger = true;
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "libvirtd"
        ];
        packages = with pkgs; [ ];
      };
    };
}
