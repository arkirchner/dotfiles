{ ... }:
{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
