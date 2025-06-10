{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.nvf.url = "github:notashelf/nvf";

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      armin-pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nvf.nixosModules.default
          ./machines/x600/configuration.nix
          ./nixos_modules/default.nix
        ];
      };

      armin-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nvf.nixosModules.default
          ./machines/720s/configuration.nix
          ./nixos_modules/default.nix
        ];
      };

      armin-work-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nvf.nixosModules.default
          ./machines/dell_5450/configuration.nix
          ./nixos_modules/default.nix
        ];
      };
    };
  };
}
