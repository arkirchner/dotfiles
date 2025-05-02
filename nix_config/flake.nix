{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      armin-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/720s/configuration.nix
          ./nixos_modules/default.nix
        ];
      };

      armin-work-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/dell_5450/configuration.nix
          ./nixos_modules/default.nix
        ];
      };
    };
  };
}
