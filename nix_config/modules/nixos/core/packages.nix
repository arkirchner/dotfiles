{ ... }:
{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        git
        samba
        lxqt.lxqt-policykit
        slack
        zoom-us
      ];

      environment.sessionVariables = {
        # Enable wayland support for chromium and electron
        NIXOS_OZONE_WL = "1";
        CONTAINERD_ENABLE_DEPRECATED_PULL_SCHEMA_1_IMAGE = "1";
      };
    };
}
