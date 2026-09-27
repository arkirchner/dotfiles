{ ... }:
{
  flake.modules.nixos.nix = {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-generations +5";
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
