{ ... }:
{
  flake.modules.nixos.nix = {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-generations +5";
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Hardlink identical files in the store instead of copying them.
      auto-optimise-store = true;

      # Members of wheel can run nix without sudo. The default is ["root"].
      trusted-users = [ "@wheel" ];
    };
  };
}
